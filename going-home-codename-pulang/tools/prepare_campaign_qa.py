"""Create an isolated source snapshot whose Web entry point runs CampaignTests."""
from pathlib import Path
import shutil
import tempfile


def prepare(root):
    storage = root / ".godot-test"
    storage.mkdir(exist_ok=True)
    target = Path(tempfile.mkdtemp(prefix="campaign-web-qa-", dir=storage))
    for folder in ("scripts", "scenes", "data", "assets"):
        shutil.copytree(root / folder, target / folder,
                        ignore=shutil.ignore_patterns("screenshots", "*.import", "__pycache__"))
    shutil.copy2(root / "icon.svg", target / "icon.svg")
    (target / "tests").mkdir()
    for name in ("CampaignTests.tscn", "campaign_tests.gd", "test_runner.gd"):
        shutil.copy2(root / "tests" / name, target / "tests" / name)
    (target / "tools").mkdir()
    shutil.copy2(root / "tools/export_beta.ps1", target / "tools/export_beta.ps1")
    project = (root / "project.godot").read_text(encoding="utf8")
    project = project.replace('run/main_scene="res://scenes/boot/Boot.tscn"',
                              'run/main_scene="res://tests/CampaignTests.tscn"')
    project = project.replace('config/name="PULANG"', 'config/name="PULANG Campaign QA"')
    (target / "project.godot").write_text(project, encoding="utf8")
    presets = (root / "export_presets.cfg").read_text(encoding="utf8")
    presets = presets.replace("tests/*,tools/*,docs/*", "tools/*,docs/*,export/*")
    (target / "export_presets.cfg").write_text(presets, encoding="utf8")
    return target


if __name__ == "__main__":
    print(prepare(Path(__file__).resolve().parents[1]))
