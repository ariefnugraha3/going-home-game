"""Reproducible, original placeholder loops; Python standard library only."""
from pathlib import Path
import math
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[1] / "assets" / "audio"
ROOT.mkdir(parents=True, exist_ok=True)
RATE = 22050
random.seed(250)

def write(name, duration, sample):
    count = int(RATE * duration)
    data = bytearray()
    for i in range(count):
        # Short edge fade keeps looping synthetic ambience free of clicks.
        envelope = min(1, i / 300, (count - i - 1) / 300)
        value = max(-1, min(1, sample(i / RATE))) * envelope
        data.extend(struct.pack("<h", int(value * 24000)))
    with wave.open(str(ROOT / (name + ".wav")), "wb") as out:
        out.setparams((1, 2, RATE, count, "NONE", "not compressed"))
        out.writeframes(data)

write("bike_idle", 4, lambda t: .36 * math.sin(math.tau * 42 * t) + .15 * math.sin(math.tau * 84 * t) + .07 * math.sin(math.tau * 126 * t) + .035 * random.uniform(-1, 1))
write("bike_load", 4, lambda t: .27 * math.sin(math.tau * 78 * t) + .13 * math.sin(math.tau * 156 * t) + .08 * math.sin(math.tau * 234 * t) + .055 * random.uniform(-1, 1))
filtered = 0.0
def wind(t):
    global filtered
    filtered = filtered * .96 + random.uniform(-1, 1) * .04
    return filtered * 2.3
write("wind", 8, wind)
write("rain", 8, lambda t: random.uniform(-.35, .35) * (.8 + .2 * math.sin(t * 4)))
def birds(t):
    phase = t % 3.8
    chirp = max(0, 1 - abs(phase - .45) / .18)
    return .19 * chirp * math.sin(math.tau * (1800 * t + 80 * math.sin(t * 30)))
write("birds", 16, birds)
for name in ["bike_idle", "bike_load", "wind", "rain", "birds"]:
    path = ROOT / (name + ".wav.import")
    path.write_text('[remap]\nimporter="wav"\ntype="AudioStreamWAV"\n\n[deps]\nsource_file="res://assets/audio/' + name + '.wav"\n\n[params]\nforce/8_bit=false\nforce/mono=true\nforce/max_rate=false\nedit/trim=false\nedit/normalize=false\nedit/loop_mode=2\nedit/loop_begin=0\nedit/loop_end=-1\ncompress/mode=2\n')
print("Generated five original placeholder loops.")
