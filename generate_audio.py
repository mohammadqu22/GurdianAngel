#!/usr/bin/env python3
"""
Generates pre-recorded MP3 files for every protocol step in every language.

Output layout:
  assets/audio/en/{emergencyId}/step_{n}.mp3
  assets/audio/he/{emergencyId}/step_{n}.mp3
  assets/audio/ar/{emergencyId}/step_{n}.mp3

Text spoken per step: "{title}. {instruction}"
"""

import subprocess
import sys
import os
import json

# ── Ensure gTTS is available ─────────────────────────────────────────────────
try:
    from gtts import gTTS
except ImportError:
    print("gTTS not found — installing with --break-system-packages...")
    subprocess.check_call([
        sys.executable, "-m", "pip", "install", "gtts",
        "--break-system-packages", "--quiet",
    ])
    from gtts import gTTS

# ── Configuration ─────────────────────────────────────────────────────────────
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

LANGUAGES = {
    "en": {"json_dir": "assets/data",     "gtts_lang": "en"},
    "he": {"json_dir": "assets/data/he",  "gtts_lang": "iw"},
    "ar": {"json_dir": "assets/data/ar",  "gtts_lang": "ar"},
}

EMERGENCY_IDS = [
    "bleeding", "burns", "choking", "choking_infant",
    "cpr", "cpr_infant", "fractures", "seizures",
]

# ── Generate ──────────────────────────────────────────────────────────────────
total = 0
skipped = 0

for lang_code, cfg in LANGUAGES.items():
    for eid in EMERGENCY_IDS:
        json_path = os.path.join(SCRIPT_DIR, cfg["json_dir"], f"{eid}.json")
        if not os.path.exists(json_path):
            print(f"  [SKIP] {json_path} not found")
            continue

        with open(json_path, encoding="utf-8") as f:
            data = json.load(f)

        steps = data.get("steps", [])
        if not steps:
            print(f"  [SKIP] {lang_code}/{eid}: no steps")
            continue

        out_dir = os.path.join(SCRIPT_DIR, "assets", "audio", lang_code, eid)
        os.makedirs(out_dir, exist_ok=True)

        for step in steps:
            n = step["step"]          # 1-indexed number from JSON
            title = step.get("title", "")
            instruction = step.get("instruction", "")
            text = f"{title}. {instruction}"

            out_path = os.path.join(out_dir, f"step_{n}.mp3")

            if os.path.exists(out_path):
                print(f"  [SKIP] {lang_code}/{eid}/step_{n}.mp3 already exists")
                skipped += 1
                continue

            print(f"  [GEN]  {lang_code}/{eid}/step_{n}.mp3")
            tts = gTTS(text=text, lang=cfg["gtts_lang"], slow=False)
            tts.save(out_path)
            total += 1

print(f"\nDone. Generated: {total}  Skipped (already existed): {skipped}")
