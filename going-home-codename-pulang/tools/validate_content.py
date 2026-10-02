"""Read-only checks for PULANG's current JSON authoring contracts (Python 3.11+)."""
from __future__ import annotations

import argparse
import json
import math
import re
from pathlib import Path
import sys
import wave


class ContentError(ValueError):
    pass


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ContentError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def read_json(path):
    def invalid_constant(value):
        raise ContentError(f"non-finite JSON number: {value}")
    return json.loads(path.read_text(encoding="utf-8-sig"),
                      object_pairs_hook=unique_object, parse_constant=invalid_constant)


class Validator:
    CLIPS = {"rest", "listen", "phone", "pack", "ride", "passenger", "walk", "wake"}
    LOCATIONS = {"apartment", "office", "parking", "memory"}
    REQUIRED = ("chapters/karawang.json", "chapters/practice.json", "dialogue/slice.json",
                "cutscenes/opening.json", "phone/messages.json", "phone/calls.json",
                "phone/photos.json", "audio/cinematic.json", "audio/soundscape.json")

    def __init__(self, root):
        self.root = Path(root).resolve()
        self.errors = []
        self.warnings = []
        self.texts = {}
        self.localized_texts = {}
        self.documents = {}

    def error(self, at, message):
        self.errors.append(f"{at}: {message}")

    def require(self, condition, at, message):
        if not condition:
            self.error(at, message)
        return condition

    def mapping(self, value, at):
        if not isinstance(value, dict):
            self.error(at, "expected an object")
            return {}
        return value

    def array(self, value, at):
        if not isinstance(value, list):
            self.error(at, "expected an array")
            return []
        return value

    def text(self, value, at, optional=False, localizable=True):
        valid = isinstance(value, str) and (optional or bool(value.strip()))
        if self.require(valid, at, "expected nonempty text" if not optional else "expected text"):
            self.texts[at] = value
            if localizable:
                self.localized_texts[at] = value

    def identifier(self, value, at, optional=False):
        return self.require(isinstance(value, str) and (optional or bool(value.strip())), at, "expected an ID")

    def number(self, value, at, low=0, high=math.inf):
        return self.require(type(value) in (int, float) and math.isfinite(value)
                            and low <= value <= high, at, f"expected finite number in [{low}, {high}]")

    def vector(self, value, at):
        if not self.require(isinstance(value, list) and len(value) == 3, at, "expected a 3D vector"):
            return
        for i, component in enumerate(value):
            self.number(component, f"{at}/{i}", -math.inf)

    def records(self, value, at, key="id"):
        seen = set()
        for i, raw in enumerate(self.array(value, at)):
            location = f"{at}/{i}"
            row = self.mapping(raw, location)
            identity = row.get(key)
            if not self.require(isinstance(identity, str) and bool(identity.strip()), location, f"missing {key}"):
                continue
            self.require(identity not in seen, location, f"duplicate {key}: {identity}")
            seen.add(identity)
            yield row, location

    def resource(self, value, at):
        if not self.require(isinstance(value, str) and value.startswith("res://"), at, "expected res:// resource"):
            return None
        path = (self.root / value[6:]).resolve()
        if not self.require(path.is_relative_to(self.root), at, "resource escapes project"):
            return None
        if not self.require(path.is_file(), at, f"missing resource: {value}"):
            return None
        return path

    def reference(self, value, table, at):
        self.require(isinstance(value, str) and value in table, at, f"unknown reference: {value!r}")

    def load(self):
        for name in self.REQUIRED:
            self.require((self.root / "data" / name).is_file(), f"data/{name}", "required content file missing")
        for path in sorted((self.root / "data").rglob("*.json")):
            name = path.relative_to(self.root).as_posix()
            known = name[5:] in self.REQUIRED or any(name.startswith(f"data/{folder}/")
                                                      for folder in ("chapters", "dialogue", "cutscenes", "localization"))
            if not known:
                self.warnings.append(f"{name}: no registered schema; only JSON syntax is checked")
            try:
                self.documents[name] = read_json(path)
            except (OSError, ValueError) as error:
                self.error(name, str(error))

    def bundles(self, folder):
        merged = {}
        for path, data in self.documents.items():
            if path.startswith(f"data/{folder}/"):
                for identity, record in self.mapping(data, path).items():
                    at = f"{path}#/{identity}"
                    self.require(bool(identity.strip()), at, "empty ID")
                    self.require(identity not in merged, at, f"duplicate {folder} ID: {identity}")
                    merged[identity] = (self.mapping(record, at), at)
        return merged

    def dialogue(self):
        dialogues = self.bundles("dialogue")
        for _, (data, at) in dialogues.items():
            nodes = self.mapping(data.get("nodes"), at + "/nodes")
            self.require("start" in nodes, at, "missing start node")
            self.require("end" not in nodes, at, "end is a reserved terminal ID")
            edges = {}
            for identity, raw in nodes.items():
                loc = f"{at}/nodes/{identity}"
                node = self.mapping(raw, loc)
                self.text(node.get("speaker"), loc + "/speaker")
                choices = self.array(node.get("choices", []), loc + "/choices")
                if "text" in node or not choices:
                    self.text(node.get("text"), loc + "/text")
                self.mapping(node.get("set", {}), loc + "/set")
                targets = []
                for i, raw_choice in enumerate(choices):
                    choice_at = f"{loc}/choices/{i}"
                    choice = self.mapping(raw_choice, choice_at)
                    self.text(choice.get("text"), choice_at + "/text")
                    self.mapping(choice.get("set", {}), choice_at + "/set")
                    self.mapping(choice.get("conditions", {}), choice_at + "/conditions")
                    targets.append(choice.get("next", "end"))
                if choices:
                    self.require(any(isinstance(c, dict) and not c.get("conditions") for c in choices), loc,
                                 "choices need an unconditional fallback to avoid a flag-dependent dead end")
                else:
                    targets.append(node.get("next", "end"))
                edges[identity] = [t for t in targets if isinstance(t, str)]
                for target in targets:
                    self.reference(target, set(nodes) | {"end"}, loc + "/next")
            reached, pending = set(), ["start"]
            while pending:
                node = pending.pop()
                if node in reached or node == "end":
                    continue
                reached.add(node)
                pending.extend(edges.get(node, []))
            for node in set(nodes) - reached:
                self.error(at + "/nodes/" + node, "unreachable from start")
            terminating = {"end"}
            while True:
                added = {node for node, targets in edges.items() if any(t in terminating for t in targets)} - terminating
                if not added:
                    break
                terminating.update(added)
            for node in reached - terminating:
                self.error(at + "/nodes/" + node, "no path to end (trapped dialogue cycle)")
        return dialogues

    def audio_bank(self, data, at):
        result = self.mapping(data, at)
        for identity, raw in result.items():
            loc = at + "/" + identity
            cue = self.mapping(raw, loc)
            self.number(cue.get("gain_db"), loc + "/gain_db", -80, 6)
            path = self.resource(cue.get("path"), loc + "/path")
            if path:
                try:
                    with wave.open(str(path), "rb") as stream:
                        self.require(stream.getnframes() > 0 and stream.getframerate() > 0, loc, "empty WAV")
                        remaining = stream.getnframes()
                        while remaining:
                            frames = min(4096, remaining)
                            expected = frames * stream.getnchannels() * stream.getsampwidth()
                            if not self.require(len(stream.readframes(frames)) == expected, loc, "truncated WAV data"):
                                break
                            remaining -= frames
                except (wave.Error, EOFError, OSError) as error:
                    self.error(loc, f"invalid PCM WAV: {error}")
        return result

    def cutscenes(self, cues):
        for _, (data, at) in self.bundles("cutscenes").items():
            self.reference(data.get("location"), self.LOCATIONS, at + "/location")
            for field in ("title", "subtitle", "purpose", "audio_priority"):
                self.text(data.get(field), at + "/" + field, localizable=field in ("title", "subtitle"))
            shots = self.array(data.get("shots"), at + "/shots")
            self.require(bool(shots), at, "sequence must have shots")
            for shot, loc in self.records(shots, at + "/shots", "shot_id"):
                duration = shot.get("duration")
                valid_duration = self.number(duration, loc + "/duration", 0.01)
                self.number(shot.get("fov", 52), loc + "/fov", 1, 179)
                for field in ("camera", "target"):
                    self.vector(shot.get(field), loc + "/" + field)
                self.require(shot.get("camera") != shot.get("target"), loc, "camera and look target coincide")
                if "camera_end" in shot:
                    self.vector(shot["camera_end"], loc + "/camera_end")
                self.text(shot.get("text"), loc + "/text", optional=True)
                for field in ("framing", "movement", "transition"):
                    self.text(shot.get(field), loc + "/" + field, localizable=False)
                for field in ("screen", "phone", "title", "subtitle"):
                    if field in shot:
                        self.text(shot[field], loc + "/" + field, optional=True)
                self.reference(shot.get("location", data.get("location")), self.LOCATIONS, loc + "/location")
                for field, default in (("performance", "rest"), ("npc_performance", "listen")):
                    self.reference(shot.get(field, default), self.CLIPS, loc + "/" + field)
                if shot.get("performance") == "walk":
                    for field in ("actor_from", "actor_to"):
                        self.vector(shot.get(field), loc + "/" + field)
                    self.require(type(shot.get("walk_cycles")) is int and shot["walk_cycles"] >= 1, loc, "walk_cycles must be a positive integer")
                previous = -1
                for i, raw in enumerate(self.array(shot.get("audio", []), loc + "/audio")):
                    event_at = f"{loc}/audio/{i}"
                    event = self.mapping(raw, event_at)
                    self.reference(event.get("cue"), cues, event_at + "/cue")
                    if self.number(event.get("at"), event_at + "/at"):
                        time = event["at"]
                        self.require(time >= previous, event_at, "audio events must be ordered")
                        if valid_duration:
                            self.require(time < duration, event_at, "audio starts outside shot")
                        previous = time

    def chapters(self):
        chapters = {}
        for path, raw in self.documents.items():
            if not path.startswith("data/chapters/") or path.endswith("/practice.json"):
                continue
            data = self.mapping(raw, path)
            identity = data.get("chapter_id")
            if not self.require(isinstance(identity, str) and bool(identity.strip()), path, "missing chapter_id"):
                continue
            self.require(identity not in chapters, path, f"duplicate chapter_id: {identity}")
            chapters[identity] = (data, path)
            if "road_shape" in data:
                shape = self.mapping(data["road_shape"], path + "#/road_shape")
                for field, low, high in (("bend", 0, 35), ("wavelength", 100, 450), ("detail", 0, 4), ("rise", 0, 6), ("grade_length", 180, 450), ("phase", 0, 6.3)):
                    self.number(shape.get(field), path + "#/road_shape/" + field, low, high)
            if identity != "karawang":
                self.reference("campaign_" + identity, self.bundles("dialogue"), path + "#/encounter")
                self.reference(data.get("biome"), {"coast", "workshop", "textiles", "city", "highlands", "neighborhood", "teak", "fields", "guesthouse", "campus", "mountain", "plantation", "home"}, path + "#/biome")
                self.text(data.get("encounter_speaker"), path + "#/encounter_speaker")
                soundscape = self.mapping(self.documents.get("data/audio/soundscape.json", {}), "data/audio/soundscape.json")
                self.reference(data.get("audio_context"), self.mapping(soundscape.get("zones", {}), "data/audio/soundscape.json#/zones"), path + "#/audio_context")
                for sequence in ("arrival_shots", "closing_shots"):
                    if sequence == "closing_shots" and sequence not in data:
                        continue
                    shots = self.array(data.get(sequence), path + "#/" + sequence)
                    self.require(bool(shots), path, "campaign sequence needs shots")
                    for i, raw in enumerate(shots):
                        loc = f"{path}#/{sequence}/{i}"
                        shot = self.mapping(raw, loc)
                        self.number(shot.get("duration"), loc + "/duration", .1, 60)
                        self.vector(shot.get("camera"), loc + "/camera")
                        self.vector(shot.get("target"), loc + "/target")
                        if "camera_end" in shot:
                            self.vector(shot["camera_end"], loc + "/camera_end")
                        self.reference(shot.get("action", ""), {"", "bike", "enter", "approach", "park", "engine_off", "mother", "bike_approach", "odometer"}, loc + "/action")
                        self.require(shot.get("camera") != shot.get("target"), loc, "camera and look target coincide")
                        self.text(shot.get("text"), loc + "/text", optional=True)
            for field in ("display_name", "theme", "start_location", "end_location"):
                self.text(data.get(field), path + "#/" + field, localizable=field != "theme")
            length = data.get("main_route_length")
            length_ok = self.number(length, path + "#/main_route_length", 1)
            stops = set()
            for stop, loc in self.records(data.get("stops"), path + "#/stops"):
                stops.add(stop["id"])
                self.number(stop.get("distance"), loc + "/distance", 0, length if length_ok else math.inf)
                for field in ("label", "title"):
                    self.text(stop.get(field), loc + "/" + field)
            for event in self.array(data.get("mandatory_events"), path + "#/mandatory_events"):
                self.reference(event, stops, path + "#/mandatory_events")
            previous = -1
            for i, raw_weather in enumerate(self.array(data.get("atmosphere"), path + "#/atmosphere")):
                loc = f"{path}#/atmosphere/{i}"
                weather = self.mapping(raw_weather, loc)
                if self.number(weather.get("distance"), loc + "/distance", 0, length if length_ok else math.inf):
                    self.require(weather["distance"] > previous, loc, "weather distances must increase")
                    previous = weather["distance"]
                profile = weather.get("profile")
                if self.require(isinstance(profile, str) and profile.isidentifier(), loc, "invalid weather profile ID"):
                    self.resource(f"res://data/weather/{profile}.tres", loc + "/profile")
            journal = self.mapping(data.get("journal"), path + "#/journal")
            self.identifier(journal.get("id"), path + "#/journal/id")
            self.text(journal.get("prompt"), path + "#/journal/prompt")
            options = list(self.records(journal.get("options"), path + "#/journal/options"))
            self.require(bool(options), path, "journal needs options")
            for option, loc in options:
                self.text(option.get("text"), loc + "/text")
        for identity, (data, path) in chapters.items():
            target = data.get("next_chapter_id", "")
            if not isinstance(target, str):
                self.error(path + "#/next_chapter_id", "expected chapter ID or empty terminal value")
            elif target and target not in chapters:
                self.error(path + "#/next_chapter_id", f"missing chapter: {target}")
        visited, current = set(), "karawang"
        while isinstance(current, str) and current and current in chapters and current not in visited:
            visited.add(current)
            current = chapters[current][0].get("next_chapter_id", "")
        self.require(not current, "data/chapters", "campaign route must terminate without a cycle")
        self.require(visited == set(chapters), "data/chapters", "all chapters must be reachable from Karawang")

    def phone(self, dialogues):
        fields = {"messages": ("from", "type", "text", "reply"),
                  "calls": ("from", "when", "direction", "note"),
                  "photos": ("title", "when", "caption")}
        for kind, required in fields.items():
            path = f"data/phone/{kind}.json"
            for row, at in self.records(self.documents.get(path), path + "#"):
                for field in required:
                    self.text(row.get(field), at + "/" + field, localizable=field not in ("type", "direction"))
                if kind == "messages":
                    self.reference(row.get("type"), {"Messages", "Email"}, at + "/type")
                    self.number(row.get("delay_seconds", 0), at + "/delay_seconds")
                    self.identifier(row.get("condition"), at + "/condition")
                elif kind == "photos":
                    self.resource(row.get("image"), at + "/image")
                    self.identifier(row.get("condition"), at + "/condition", optional=True)
                else:
                    target = row.get("dialogue")
                    self.reference(target, dialogues, at + "/dialogue")
                    if isinstance(target, str) and target in dialogues:
                        nodes = dialogues[target][0].get("nodes", {})
                        if isinstance(nodes, dict):
                            self.reference(row.get("remembered_node"), nodes, at + "/remembered_node")

    def localization(self):
        references = {}
        used = {}

        def walk(value, at):
            if isinstance(value, list):
                for index, child in enumerate(value):
                    walk(child, f"{at}/{index}")
            elif isinstance(value, dict):
                bindings = self.mapping(value.get("text_keys", {}), at + "/text_keys")
                for field, key in bindings.items():
                    location = at + "/" + field
                    if not self.require(location in self.localized_texts, location, "text key targets an unknown or non-localizable field"):
                        continue
                    if not self.require(isinstance(key, str) and re.fullmatch(r"[a-z][a-z0-9_.]*", key), location, "invalid localization key"):
                        continue
                    self.require(key not in used, location, f"duplicate localization key: {key}")
                    used[key] = location
                    references[location] = key
                for field, child in value.items():
                    if field != "text_keys":
                        walk(child, at + "/" + field)

        for path, data in self.documents.items():
            if not path.startswith("data/localization/"):
                walk(data, path + "#")
        for at in self.localized_texts:
            self.require(at in references, at, "missing localization key")
        english_path = "data/localization/en.json"
        self.require(english_path in self.documents, english_path, "English catalog is required")
        for path, data in self.documents.items():
            if not path.startswith("data/localization/"):
                continue
            catalog = self.mapping(data, path)
            locale = Path(path).stem
            self.require(catalog.get("locale") == locale, path, "catalog locale must match filename")
            strings = self.mapping(catalog.get("strings"), path + "#/strings")
            for key, at in used.items():
                if not self.require(key in strings, path, f"missing catalog key: {key}"):
                    continue
                value = strings[key]
                source = self.localized_texts[at]
                valid = isinstance(value, str) and (bool(value.strip()) or source == value == "")
                self.require(valid, path + "#/strings/" + key, "expected translated text (blank only for blank source)")
                if locale == "en":
                    self.require(value == source, at, f"English catalog differs from source: {key}")
            for key in set(strings) - set(used):
                self.error(path + "#/strings/" + key, "unused catalog key")
        return dict(sorted(references.items()))

    def run(self, check_localization=True):
        self.load()
        dialogues = self.dialogue()
        cues = self.audio_bank(self.documents.get("data/audio/cinematic.json"), "data/audio/cinematic.json#")
        sound = self.mapping(self.documents.get("data/audio/soundscape.json"), "data/audio/soundscape.json#")
        for bank in ("ui", "music"):
            self.audio_bank(sound.get(bank), f"data/audio/soundscape.json#/{bank}")
        zones = self.mapping(sound.get("zones"), "data/audio/soundscape.json#/zones")
        for identity, raw in zones.items():
            for layer, value in self.mapping(raw, f"zones/{identity}").items():
                self.number(value, f"zones/{identity}/{layer}", 0, 1)
        for i, raw in enumerate(self.array(sound.get("karawang_regions"), "karawang_regions")):
            at = f"data/audio/soundscape.json#/karawang_regions/{i}"
            region = self.mapping(raw, at)
            start_ok = self.number(region.get("from"), at + "/from")
            end_ok = self.number(region.get("to"), at + "/to")
            if start_ok and end_ok:
                self.require(region["to"] > region["from"], at, "region must have positive length")
            self.reference(region.get("zone"), zones, at + "/zone")
        self.cutscenes(cues)
        self.chapters()
        self.phone(dialogues)
        practice = self.mapping(self.documents.get("data/chapters/practice.json"), "data/chapters/practice.json#")
        length_ok = self.number(practice.get("length"), "practice/length", 1)
        previous = 0
        sections = list(self.records(practice.get("sections"), "data/chapters/practice.json#/sections"))
        self.require(bool(sections), "data/chapters/practice.json#/sections", "practice needs sections")
        for section, at in sections:
            start_ok = self.number(section.get("start"), at + "/start", previous)
            end_ok = self.number(section.get("end"), at + "/end", 0, practice["length"] if length_ok else math.inf)
            if start_ok and end_ok:
                self.require(section["end"] > section["start"], at, "section must have positive length")
                previous = section["end"]
            for field in ("name", "sign", "hint"):
                self.text(section.get(field), at + "/" + field)
        keys = self.localization() if check_localization else {}
        return {"files": len(self.documents), "errors": self.errors, "warnings": self.warnings,
                "text_inventory": dict(sorted(self.texts.items())), "localization_keys": keys}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--format", choices=("text", "json"), default="text")
    parser.add_argument("--strict", action="store_true", help="fail on warnings, including planned chapter boundaries")
    args = parser.parse_args(argv)
    report = Validator(args.project).run()
    if args.format == "json":
        print(json.dumps(report, ensure_ascii=True, indent=2))
    else:
        for severity in ("errors", "warnings"):
            for diagnostic in report[severity]:
                print(f"{severity.upper()}: {diagnostic}")
        print(f"CONTENT RESULT: {report['files']} files, {len(report['errors'])} errors, "
              f"{len(report['warnings'])} warnings, {len(report['text_inventory'])} text fields")
    return 1 if report["errors"] or (args.strict and report["warnings"]) else 0


if __name__ == "__main__":
    sys.exit(main())
