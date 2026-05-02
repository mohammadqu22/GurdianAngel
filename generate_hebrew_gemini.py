#!/usr/bin/env python3
"""
Generates Hebrew TTS audio using Gemini 3.1 Flash TTS (paid tier).
Overwrites existing Google Cloud WaveNet Hebrew WAVs.


Run: python3 generate_hebrew_gemini.py
"""

import base64
import json
import os
import time
import wave

import requests

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

EMERGENCY_IDS = [
    "bleeding", "burns", "choking", "choking_infant",
    "cpr", "cpr_infant", "fractures", "seizures",
]

SAMPLE_RATE  = 24000
CHANNELS     = 1
SAMPLE_WIDTH = 2

_GEMINI_URL = (
    "https://generativelanguage.googleapis.com/v1beta/models/"
    "gemini-3.1-flash-tts-preview:generateContent"
)
_MAX_RETRIES = 5


def _load_api_key() -> str:
    key = os.environ.get("GEMINI_API_KEY", "")
    if not key:
        try:
            with open(os.path.join(SCRIPT_DIR, ".env"), encoding="utf-8") as f:
                for line in f:
                    if line.strip().startswith("GEMINI_API_KEY="):
                        key = line.strip().split("=", 1)[1].strip()
        except FileNotFoundError:
            pass
    return key


def _generate_pcm(text: str, api_key: str) -> bytes:
    payload = {
        "contents": [{"parts": [{"text": text}]}],
        "generationConfig": {
            "responseModalities": ["AUDIO"],
            "speechConfig": {
                "voiceConfig": {"prebuiltVoiceConfig": {"voiceName": "Kore"}},
            },
        },
    }
    for attempt in range(_MAX_RETRIES):
        resp = requests.post(
            _GEMINI_URL, params={"key": api_key}, json=payload, timeout=30
        )
        if resp.status_code == 429:
            wait = int(resp.headers.get("Retry-After", 60 * (attempt + 1)))
            print(f"\n    [RATE LIMIT] waiting {wait}s...", end=" ", flush=True)
            time.sleep(wait)
            continue
        resp.raise_for_status()
        data = resp.json()
        b64 = data["candidates"][0]["content"]["parts"][0]["inlineData"]["data"]
        return base64.b64decode(b64)
    raise RuntimeError("Exceeded max retries")


def _save_wav(pcm: bytes, path: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with wave.open(path, "wb") as wf:
        wf.setnchannels(CHANNELS)
        wf.setsampwidth(SAMPLE_WIDTH)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(pcm)


def main() -> None:
    api_key = _load_api_key()
    if not api_key or api_key == "YOUR_KEY_HERE":
        print("Error: GEMINI_API_KEY not set in .env")
        return

    generated = errors = 0

    for eid in EMERGENCY_IDS:
        json_path = os.path.join(SCRIPT_DIR, "assets", "data", "he", f"{eid}.json")
        if not os.path.exists(json_path):
            print(f"  [SKIP] {json_path} not found")
            continue

        with open(json_path, encoding="utf-8") as f:
            data = json.load(f)

        for step in data.get("steps", []):
            n    = step["step"]
            text = f"{step.get('title', '')}. {step.get('instruction', '')}"
            path = os.path.join(SCRIPT_DIR, "assets", "audio", "he", eid, f"step_{n}.wav")

            print(f"  [GEN]  he/{eid}/step_{n}.wav ...", end=" ", flush=True)
            try:
                pcm = _generate_pcm(text, api_key)
                _save_wav(pcm, path)
                print("OK")
                generated += 1
            except Exception as exc:
                print(f"ERROR: {exc}")
                errors += 1

    print(f"\nDone.  Generated: {generated}  Errors: {errors}")


if __name__ == "__main__":
    main()
