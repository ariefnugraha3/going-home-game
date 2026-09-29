"""Explicitly seed missing stable text keys and English entries; never overwrite translations."""
import argparse
import json
from pathlib import Path
import re
from validate_content import Validator, read_json


def seed(root, write=False):
    validator = Validator(root)
    report = validator.run(check_localization=False)
    if report["errors"]:
        raise ValueError("Fix content errors before seeding:\n" + "\n".join(report["errors"]))
    root = Path(root)
    catalog_path = root / "data/localization/en.json"
    catalog = read_json(catalog_path) if catalog_path.exists() else {"locale": "en", "strings": {}}
    if not isinstance(catalog, dict) or catalog.get("locale") != "en" or not isinstance(catalog.get("strings"), dict):
        raise ValueError("Invalid English catalog")
    used = set(catalog["strings"])
    owners = set()
    dirty = set()
    added = 0
    # Reserve all existing bindings before allocating keys for newly authored text.
    for at in validator.localized_texts:
        name, pointer = at.split("#", 1)
        value = validator.documents[name]
        parts = pointer.strip("/").split("/")
        for part in parts[:-1]:
            value = value[int(part)] if isinstance(value, list) else value[part]
        bindings = value.get("text_keys", {})
        if not isinstance(bindings, dict):
            raise ValueError(f"Invalid text_keys: {at}")
        key = bindings.get(parts[-1])
        if key is not None:
            if not isinstance(key, str) or not re.fullmatch(r"[a-z][a-z0-9_.]*", key) or key in owners:
                raise ValueError(f"Invalid or duplicate existing key: {at}")
            owners.add(key)
            used.add(key)
    for at, text in sorted(validator.localized_texts.items()):
        name, pointer = at.split("#", 1)
        value = validator.documents[name]
        parts = pointer.strip("/").split("/")
        for part in parts[:-1]:
            value = value[int(part)] if isinstance(value, list) else value[part]
        bindings = value.setdefault("text_keys", {})
        key = bindings.get(parts[-1])
        if key is None:
            base = re.sub(r"[^a-z0-9_.]+", ".", (name[5:-5] + pointer).lower()).strip(".")
            key = base
            index = 2
            while key in used:
                key = f"{base}_{index}"
                index += 1
            used.add(key)
            bindings[parts[-1]] = key
            dirty.add(name)
            added += 1
        if key not in catalog["strings"]:
            catalog["strings"][key] = text
    outputs = {name: validator.documents[name] for name in dirty}
    if not catalog_path.exists() or catalog != read_json(catalog_path):
        catalog["strings"] = dict(sorted(catalog["strings"].items()))
        outputs["data/localization/en.json"] = catalog
    if write:
        for name, data in outputs.items():
            destination = root / name
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return {"new_keys": added, "files": sorted(outputs), "written": write}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--write", action="store_true", help="apply additions (default: dry run)")
    args = parser.parse_args()
    try:
        print(json.dumps(seed(args.project, args.write), indent=2))
    except (ValueError, OSError) as error:
        parser.exit(1, str(error) + "\n")
