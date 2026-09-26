"""Original short, softly enveloped UI tones; Python standard library only."""
from pathlib import Path
import math
import struct
import wave

ROOT = Path(__file__).resolve().parents[1] / "assets" / "audio"
RATE = 22050


def write(name, duration, notes):
    count = int(RATE * duration)
    samples = bytearray()
    for index in range(count):
        time = index / RATE
        value = 0.0
        for start, pitch, length, strength in notes:
            age = time - start
            if 0 <= age < length:
                envelope = min(1.0, age / .008, (length - age) / .020)
                value += strength * envelope * math.exp(-age * 18) * math.sin(math.tau * pitch * age)
        samples.extend(struct.pack("<h", round(max(-.9, min(.9, value)) * 32767)))
    with wave.open(str(ROOT / (name + ".wav")), "wb") as out:
        out.setparams((1, 2, RATE, count, "NONE", "not compressed"))
        out.writeframes(samples)
    metadata = ROOT / (name + ".wav.import")
    if not metadata.exists():
        metadata.write_text('[remap]\nimporter="wav"\ntype="AudioStreamWAV"\n\n[deps]\nsource_file="res://assets/audio/' + name + '.wav"\n\n[params]\nforce/mono=true\nedit/loop_mode=1\ncompress/mode=0\n')


write("ui_select", .10, [(0, 480, .10, .28)])
write("ui_confirm", .18, [(0, 480, .10, .24), (.065, 640, .115, .22)])
write("ui_back", .12, [(0, 360, .12, .26)])
print("Generated three original nonlooping UI cues.")
