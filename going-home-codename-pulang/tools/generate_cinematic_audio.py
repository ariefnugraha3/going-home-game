"""Original cinematic sound sketches; deterministic, standard-library synthesis."""
from pathlib import Path
import math
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[1] / "assets" / "audio"
RATE = 22050


def tone(t, start, length, pitch, strength):
    age = t - start
    if not 0 <= age < length:
        return 0.0
    envelope = min(1.0, age / .02, (length - age) / .06)
    return strength * envelope * math.sin(math.tau * pitch * age)


def write(name, duration, sample):
    rng = random.Random(71)
    count = round(RATE * duration)
    samples = bytearray()
    smooth_noise = 0.0
    for index in range(count):
        t = index / RATE
        smooth_noise = .85 * smooth_noise + .15 * rng.uniform(-1, 1)
        envelope = min(1.0, t / .03, (duration - t) / .12)
        value = envelope * sample(t, smooth_noise)
        samples.extend(struct.pack("<h", round(max(-.9, min(.9, value)) * 32767)))
    with wave.open(str(ROOT / (name + ".wav")), "wb") as out:
        out.setparams((1, 2, RATE, count, "NONE", "not compressed"))
        out.writeframes(samples)
    metadata = ROOT / (name + ".wav.import")
    if not metadata.exists():
        metadata.write_text('[remap]\nimporter="wav"\ntype="AudioStreamWAV"\n\n[deps]\nsource_file="res://assets/audio/' + name + '.wav"\n\n[params]\nforce/mono=true\nedit/loop_mode=1\ncompress/mode=0\n')


write("cin_alarm", 2.0, lambda t, n: sum(tone(t, start, .18, 740, .22) for start in (.1, .4, 1.0, 1.3)))
write("cin_message", .45, lambda t, n: tone(t, .02, .2, 620, .22) + tone(t, .19, .22, 830, .18))
write("cin_phone", 2.6, lambda t, n: sum(tone(t, start, .45, 520, .16) + tone(t, start, .45, 650, .12) for start in (.1, .7, 1.7)))
write("cin_fabric", .85, lambda t, n: n * .9 * math.sin(math.pi * t / .85) ** 2 * (.65 + .35 * math.sin(130 * t)))


def memory_motor(t, noise):
    # Soft mechanical pulses and air, with a long fade into present-day silence.
    envelope = min(1.0, t / .6, (4.0 - t) / 1.4)
    phase = math.tau * (34 * t + .3 * t * t)
    pulse = .18 * math.sin(phase) + .07 * math.sin(phase * 2) + .035 * math.sin(phase * 4)
    return envelope * (pulse + .18 * noise)


write("cin_memory_motor", 4.0, memory_motor)
print("Generated five original nonlooping cinematic cues.")
