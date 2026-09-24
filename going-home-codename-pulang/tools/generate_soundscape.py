"""Original synthesized M4 soundscape and short score; no external recordings."""
from pathlib import Path
import math
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[1] / "assets" / "audio"
RATE = 22050
rng = random.Random(20260924)

def write(name, duration, sample, loop=False):
    count = int(RATE * duration)
    data = bytearray()
    for i in range(count):
        edge = min(1, i / 450, (count - i - 1) / 450)
        value = max(-.95, min(.95, sample(i / RATE))) * edge
        data.extend(struct.pack("<h", int(value * 24000)))
    with wave.open(str(ROOT / (name + ".wav")), "wb") as out:
        out.setparams((1, 2, RATE, count, "NONE", "not compressed"))
        out.writeframes(data)
    metadata = ROOT / (name + ".wav.import")
    if not metadata.exists():
        metadata.write_text('[remap]\nimporter="wav"\ntype="AudioStreamWAV"\n\n[deps]\nsource_file="res://assets/audio/' + name + '.wav"\n\n[params]\nforce/mono=true\nedit/loop_mode=' + ('2' if loop else '1') + '\nedit/loop_begin=0\nedit/loop_end=-1\ncompress/mode=2\n')

filtered = 0.0
def traffic(t):
    global filtered
    filtered = filtered * .94 + rng.uniform(-1, 1) * .06
    swell = .25 + .75 * math.sin(math.pi * t / 8) ** 4
    return swell * (.55 * filtered + .045 * math.sin(math.tau * 68 * t))

def dishes(t):
    value = 0.0
    for at, pitch in [(1.2, 1180), (1.36, 1640), (5.6, 1320), (8.1, 920)]:
        age = t - at
        if 0 <= age < .7:
            value += .10 * math.exp(-age * 12) * math.sin(math.tau * pitch * age)
    return value

def roof(t):
    tick = (t * 17) % 1
    return .12 * rng.uniform(-1, 1) + .07 * math.exp(-tick * 16) * math.sin(math.tau * 720 * t)

# Sparse original phrase: soft decaying sine harmonics, with room between notes.
NOTES = [(0.8, 64, .18), (3.3, 67, .14), (6.2, 62, .16), (10.0, 59, .17), (13.5, 62, .12), (17.0, 57, .16)]
def motif(t):
    value = 0.0
    for at, midi, strength in NOTES:
        age = t - at
        if 0 <= age < 6:
            hz = 440 * 2 ** ((midi - 69) / 12)
            envelope = (1 - math.exp(-age * 24)) * math.exp(-age / 1.6)
            value += strength * envelope * (math.sin(math.tau * hz * age) + .2 * math.sin(math.tau * hz * 2 * age))
    return value * min(1, (24 - t) / 2)

def ignition(t):
    pulse = .5 + .5 * math.sin(math.tau * 10 * t)
    return (.16 * math.sin(math.tau * (32 * t + 15 * t * t)) + .06 * rng.uniform(-1, 1)) * pulse * max(0, 1 - t / 1.4)

def cooldown(t):
    value = .10 * math.exp(-t * 7) * math.sin(math.tau * (60 * t - 9 * t * t))
    for at in [.5, 1.1, 1.8]:
        age = t - at
        if 0 <= age < .15:
            value += .055 * math.exp(-age * 45) * math.sin(math.tau * 1550 * age)
    return value

write("traffic", 8, traffic, True)
write("warung", 12, dishes, True)
write("rain_roof", 8, roof, True)
write("first_night", 24, motif)
write("ignition", 1.4, ignition)
write("cooldown", 2.4, cooldown)
print("Generated three soundscape loops, one original music cue and two vehicle cues.")
