"""Fault-injection checks. All edits are confined to disposable fixture projects."""
import contextlib
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import shutil
import sys
import tempfile
import unittest

PROJECT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("validate_content", PROJECT / "tools/validate_content.py")
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)
sys.path.insert(0, str(PROJECT / "tools"))
try:
    from seed_localization import seed
finally:
    sys.path.pop(0)


class ContentValidationTests(unittest.TestCase):
    def setUp(self):
        storage = PROJECT / ".godot-test"
        storage.mkdir(exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(prefix="content-", dir=storage)
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        shutil.copytree(PROJECT / "data", self.root / "data")
        for folder in ("audio", "photos"):
            shutil.copytree(PROJECT / "assets" / folder, self.root / "assets" / folder)

    def edit(self, path, change):
        file = self.root / "data" / path
        data = json.loads(file.read_text(encoding="utf-8"))
        change(data)
        file.write_text(json.dumps(data), encoding="utf-8")

    def report(self):
        return validator.Validator(self.root).run()

    def rejects(self, text):
        self.assertIn(text, "\n".join(self.report()["errors"]))

    def test_current_content_and_complete_route(self):
        report = self.report()
        self.assertEqual(report["errors"], [])
        self.assertEqual(report["files"], 27)
        self.assertEqual(report["warnings"], [])
        self.assertIn("data/dialogue/slice.json#/mother/nodes/home/text", report["text_inventory"])

    def test_cli_json_and_strict_exit_status(self):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            self.assertEqual(validator.main(["--project", str(self.root), "--format", "json"]), 0)
        self.assertEqual(json.loads(output.getvalue())["errors"], [])
        with contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(validator.main(["--project", str(self.root), "--strict"]), 0)

    def test_read_only_and_deterministic(self):
        def fingerprints():
            return {str(p.relative_to(self.root)): hashlib.sha256(p.read_bytes()).hexdigest()
                    for p in self.root.rglob("*") if p.is_file()}
        before = fingerprints()
        self.assertEqual(self.report(), self.report())
        self.assertEqual(fingerprints(), before)

    def test_malformed_json_reports_file(self):
        (self.root / "data/phone/messages.json").write_text("{broken", encoding="utf-8")
        self.rejects("data/phone/messages.json")

    def test_duplicate_json_keys_are_not_silently_overwritten(self):
        (self.root / "data/dialogue/duplicate.json").write_text('{"same": {}, "same": {}}', encoding="utf-8")
        self.rejects("duplicate JSON key: same")

    def test_nonfinite_json_rejected(self):
        (self.root / "data/audio/bad.json").write_text('{"value": NaN}', encoding="utf-8")
        self.rejects("non-finite JSON number")

    def test_missing_required_file(self):
        (self.root / "data/phone/calls.json").unlink()
        self.rejects("required content file missing")

    def test_wrong_root_and_nested_types_do_not_crash(self):
        for path in ("phone/messages.json", "dialogue/slice.json", "cutscenes/opening.json",
                     "chapters/karawang.json", "audio/cinematic.json", "audio/soundscape.json"):
            with self.subTest(path=path):
                file = self.root / "data" / path
                original = file.read_bytes()
                file.write_text("null", encoding="utf-8")
                self.assertTrue(self.report()["errors"])
                file.write_bytes(original)
        self.edit("dialogue/slice.json", lambda d: d["mother"].update(nodes={"start": {"choices": [None]}}))
        self.rejects("expected an object")

    def test_duplicate_dialogue_ids_across_files(self):
        (self.root / "data/dialogue/extra.json").write_text('{"mother": {"nodes": {}}}', encoding="utf-8")
        self.rejects("duplicate dialogue ID: mother")

    def test_broken_dialogue_edge(self):
        self.edit("dialogue/slice.json", lambda d: d["mother"]["nodes"]["start"].update(next="typo"))
        self.rejects("unknown reference: 'typo'")

    def test_dialogue_trapped_cycle(self):
        self.edit("dialogue/slice.json", lambda d: d["mother"]["nodes"]["key"].update(next="start"))
        self.rejects("trapped dialogue cycle")

    def test_unreachable_node(self):
        self.edit("dialogue/slice.json", lambda d: d["mother"]["nodes"].update(unused={"speaker": "Raka", "text": "Unused."}))
        self.rejects("unreachable from start")

    def test_all_conditional_choices_need_fallback(self):
        def change(data):
            for choice in data["mother"]["nodes"]["answer"]["choices"]:
                choice["conditions"] = {"unknown": True}
        self.edit("dialogue/slice.json", change)
        self.rejects("unconditional fallback")

    def test_blank_player_text(self):
        self.edit("phone/messages.json", lambda d: d[0].update(text="  "))
        self.rejects("data/phone/messages.json#/0/text: expected nonempty text")

    def test_call_dialogue_and_recollection_reference(self):
        self.edit("phone/calls.json", lambda d: d[0].update(remembered_node="missing"))
        self.rejects("remembered_node: unknown reference")
        self.edit("phone/calls.json", lambda d: d[0].update(dialogue="missing"))
        self.rejects("dialogue: unknown reference")

    def test_duplicate_message_and_negative_delay(self):
        self.edit("phone/messages.json", lambda d: d.append(dict(d[0], delay_seconds=-1)))
        self.rejects("duplicate id: mom_departure")
        self.rejects("delay_seconds: expected finite number")

    def test_resource_missing_and_path_escape(self):
        self.edit("phone/photos.json", lambda d: d[0].update(image="res://missing.png"))
        self.rejects("missing resource")
        self.edit("phone/photos.json", lambda d: d[0].update(image="res://../outside.png"))
        self.rejects("resource escapes project")

    def test_unknown_audio_and_late_event(self):
        self.edit("cutscenes/opening.json", lambda d: d["morning"]["shots"][0].update(audio=[{"cue": "missing", "at": 99}]))
        self.rejects("unknown reference: 'missing'")
        self.rejects("audio starts outside shot")

    def test_unsorted_audio_events(self):
        self.edit("cutscenes/opening.json", lambda d: d["morning"]["shots"][0].update(audio=[{"cue": "fabric", "at": 2}, {"cue": "fabric", "at": 1}]))
        self.rejects("audio events must be ordered")

    def test_invalid_wav(self):
        (self.root / "assets/audio/cin_alarm.wav").write_bytes(b"not a wave file")
        self.rejects("invalid PCM WAV")

    def test_truncated_wav_payload(self):
        path = self.root / "assets/audio/cin_alarm.wav"
        data = path.read_bytes()
        path.write_bytes(data[:len(data) // 2])
        self.rejects("truncated WAV data")

    def test_unknown_schema_is_reported(self):
        (self.root / "data/phone/extra.json").write_text("{}", encoding="utf-8")
        self.assertTrue(any("no registered schema" in item for item in self.report()["warnings"]))

    def test_empty_practice_route(self):
        self.edit("chapters/practice.json", lambda d: d.update(sections=[]))
        self.rejects("practice needs sections")

    def test_invalid_camera_duration_and_performance(self):
        self.edit("cutscenes/opening.json", lambda d: d["morning"]["shots"][0].update(camera=[0], duration=True, performance="fly"))
        self.rejects("expected a 3D vector")
        self.rejects("duration: expected finite number")
        self.rejects("unknown reference: 'fly'")

    def test_duplicate_shot_ids(self):
        self.edit("cutscenes/opening.json", lambda d: d["morning"]["shots"].append(d["morning"]["shots"][0]))
        self.rejects("duplicate shot_id: alarm")

    def test_missing_weather_and_bad_mandatory_stop(self):
        self.edit("chapters/karawang.json", lambda d: d.update(atmosphere=[{"distance": 0, "profile": "missing"}], mandatory_events=["missing"]))
        self.rejects("missing resource: res://data/weather/missing.tres")
        self.rejects("mandatory_events: unknown reference")

    def test_unplanned_chapter_is_error_not_boundary_warning(self):
        self.edit("chapters/karawang.json", lambda d: d.update(next_chapter_id="cirebno"))
        self.rejects("missing chapter: cirebno")

    def test_stop_outside_road(self):
        self.edit("chapters/karawang.json", lambda d: d["stops"][0].update(distance=99999))
        self.rejects("distance: expected finite number")

    def test_sound_zone_reference(self):
        self.edit("audio/soundscape.json", lambda d: d["karawang_regions"][0].update(zone="missing"))
        self.rejects("zone: unknown reference")

    def test_overlapping_practice_sections(self):
        self.edit("chapters/practice.json", lambda d: d["sections"][1].update(start=0))
        self.rejects("start: expected finite number")

    def line_key(self):
        data = json.loads((self.root / "data/dialogue/slice.json").read_text())
        return data["mother"]["nodes"]["home"]["text_keys"]["text"]

    def test_localization_coverage(self):
        report = self.report()
        self.assertEqual(len(report["localization_keys"]), 616)
        self.assertTrue(all("/type" not in field and "/direction" not in field for field in report["localization_keys"]))

    def test_campaign_cycle(self):
        self.edit("chapters/epilogue.json", lambda d: d.update(next_chapter_id="karawang"))
        self.rejects("campaign route must terminate")

    def test_campaign_missing_dialogue(self):
        self.edit("dialogue/campaign.json", lambda d: d.pop("campaign_kediri"))
        self.rejects("unknown reference: 'campaign_kediri'")

    def test_campaign_bad_shot(self):
        self.edit("chapters/ngawi.json", lambda d: d["arrival_shots"][0].update(duration=0))
        self.rejects("expected finite number")

    def test_road_shape_zero_wavelength(self):
        self.edit("chapters/salatiga.json", lambda d: d["road_shape"].update(wavelength=0))
        self.rejects("expected finite number")

    def test_road_shape_wrong_type(self):
        self.edit("chapters/malang.json", lambda d: d.update(road_shape=[]))
        self.rejects("expected an object")

    def test_missing_text_binding(self):
        self.edit("dialogue/slice.json", lambda d: d["mother"]["nodes"]["home"]["text_keys"].pop("text"))
        self.rejects("missing localization key")

    def test_missing_catalog_key(self):
        key = self.line_key()
        self.edit("localization/en.json", lambda d: d["strings"].pop(key))
        self.rejects("missing catalog key: " + key)

    def test_missing_english_catalog(self):
        (self.root / "data/localization/en.json").unlink()
        self.rejects("English catalog is required")

    def test_duplicate_localization_binding(self):
        key = self.line_key()
        self.edit("dialogue/slice.json", lambda d: d["mother"]["nodes"]["start"]["text_keys"].update(text=key))
        self.rejects("duplicate localization key")

    def test_invalid_binding_and_catalog_types(self):
        self.edit("dialogue/slice.json", lambda d: d["mother"]["nodes"]["home"].update(text_keys=[]))
        self.edit("localization/en.json", lambda d: d.update(strings=[]))
        self.rejects("expected an object")

    def test_invalid_key_syntax(self):
        self.edit("dialogue/slice.json", lambda d: d["mother"]["nodes"]["home"]["text_keys"].update(text="Bad key!"))
        self.rejects("invalid localization key")

    def test_cannot_bind_runtime_enum(self):
        self.edit("phone/messages.json", lambda d: d[0]["text_keys"].update(type="phone.channel"))
        self.rejects("unknown or non-localizable field")

    def test_stale_english_and_seed_never_overwrites(self):
        key = self.line_key()
        self.edit("localization/en.json", lambda d: d["strings"].update({key: "A changed catalog line"}))
        self.rejects("English catalog differs from source")
        self.assertEqual(seed(self.root, write=True)["files"], [])
        self.rejects("English catalog differs from source")

    def test_unused_catalog_key(self):
        self.edit("localization/en.json", lambda d: d["strings"].update({"unused.key": "Unused"}))
        self.rejects("unused catalog key")

    def test_optional_locale_must_be_complete(self):
        file = self.root / "data/localization/id.json"
        file.write_text('{"locale":"id", "strings":{}}', encoding="utf-8")
        self.rejects("missing catalog key")
        data = json.loads((self.root / "data/localization/en.json").read_text())
        data["locale"] = "id"
        data["strings"][self.line_key()] = "Selamat datang."
        file.write_text(json.dumps(data), encoding="utf-8")
        self.assertEqual(self.report()["errors"], [])
        data["strings"][self.line_key()] = " "
        file.write_text(json.dumps(data), encoding="utf-8")
        self.rejects("expected translated text")

    def test_catalog_locale_must_match_filename(self):
        self.edit("localization/en.json", lambda d: d.update(locale="id"))
        self.rejects("catalog locale must match filename")

    def test_choice_and_shot_reorder_preserve_keys(self):
        before = set(self.report()["localization_keys"].values())
        self.edit("dialogue/authoring_example.json", lambda d: d["authoring.greeting"]["nodes"]["start"]["choices"].reverse())
        self.edit("cutscenes/opening.json", lambda d: d["morning"]["shots"].reverse())
        after = self.report()
        self.assertEqual(after["errors"], [])
        self.assertEqual(set(after["localization_keys"].values()), before)
        self.assertEqual(seed(self.root, write=True)["files"], [])

    def test_seed_dry_run_and_idempotent_additions(self):
        self.edit("dialogue/authoring_example.json", lambda d: d["authoring.greeting"]["nodes"]["start"]["choices"].append({"text": "Goodbye.", "next": "end"}))
        path = self.root / "data/dialogue/authoring_example.json"
        before = path.read_bytes()
        result = seed(self.root)
        self.assertEqual(result["new_keys"], 1)
        self.assertEqual(path.read_bytes(), before)
        self.assertEqual(seed(self.root, write=True)["new_keys"], 1)
        self.assertEqual(self.report()["errors"], [])
        self.assertEqual(seed(self.root, write=True)["files"], [])

    def test_seed_rejects_duplicate_existing_keys(self):
        key = self.line_key()
        self.edit("dialogue/slice.json", lambda d: d["mother"]["nodes"]["start"]["text_keys"].update(text=key))
        with self.assertRaisesRegex(ValueError, "duplicate existing key"):
            seed(self.root, write=True)


if __name__ == "__main__":
    unittest.main()
