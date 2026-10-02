"""Verify chapter/narrative JSON bytes in Godot 4.7 PCK and Android debug exports."""
import hashlib
import json
from pathlib import Path
import struct
import zipfile


def read_pack(path):
    blob = path.read_bytes()
    magic, version, *_ = struct.unpack_from("<6I", blob)
    if magic != 0x43504447 or version != 4:
        raise ValueError("Expected the pinned Godot 4.7 PCK v4 format")
    base, directory = struct.unpack_from("<QQ", blob, 24)
    count, = struct.unpack_from("<I", blob, directory)
    cursor = directory + 4
    files = {}
    for _ in range(count):
        length, = struct.unpack_from("<I", blob, cursor)
        cursor += 4
        name = blob[cursor:cursor + length].rstrip(b"\0").decode("utf8")
        cursor += length
        offset, size = struct.unpack_from("<QQ", blob, cursor)
        digest = blob[cursor + 16:cursor + 32]
        flags, = struct.unpack_from("<I", blob, cursor + 32)
        cursor += 36
        if name in files or flags or base + offset + size > directory:
            raise ValueError(f"Unsupported or invalid pack entry: {name}")
        content = blob[base + offset:base + offset + size]
        if hashlib.md5(content).digest() != digest:
            raise ValueError(f"Pack entry checksum mismatch: {name}")
        files[name] = content
    return files


def audit(root):
    expected = {p.relative_to(root).as_posix(): p.read_bytes()
                for p in (root / "data").rglob("*.json")}
    web = root / "export/web/index.pck"
    apk = root / "export/android/pulang-debug.apk"
    packages = {"Web": read_pack(web)}
    with zipfile.ZipFile(apk) as archive:
        packages["Android"] = {name[7:]: archive.read(name) for name in archive.namelist()
                               if name.startswith("assets/") and not name.endswith("/")}
    for platform, files in packages.items():
        for name, content in expected.items():
            if files.get(name) != content:
                raise ValueError(f"{platform}: missing or stale content: {name}")
        unexpected = [name for name in files if name.startswith(("tests/", "tools/", "docs/", "export/"))]
        if unexpected:
            raise ValueError(f"{platform}: development/output files in export: {unexpected}")
    return {"json_files_per_platform": len(expected), "content_matches_source": True,
            "artifacts": {p.relative_to(root).as_posix(): {"bytes": p.stat().st_size,
                           "sha256": hashlib.sha256(p.read_bytes()).hexdigest()}
                          for p in [web, root / "export/web/index.wasm", apk]}}


if __name__ == "__main__":
    print(json.dumps(audit(Path(__file__).resolve().parents[1]), indent=2))
