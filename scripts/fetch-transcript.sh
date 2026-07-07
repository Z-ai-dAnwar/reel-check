#!/bin/bash
# reel-check: download a short-form video's audio and transcribe it locally.
# Usage: fetch-transcript.sh <video-url> <output-dir>
# Prints metadata (uploader, title, caption) then the transcript.
# Requires: yt-dlp, ffmpeg, whisper-cli (all via homebrew). Model auto-downloads on first run.
set -euo pipefail

URL="$1"
OUT="$2"
MODEL="$HOME/.cache/whisper-cpp/ggml-base.en.bin"

mkdir -p "$OUT"
cd "$OUT"

if [ ! -f "$MODEL" ]; then
  echo "Downloading whisper model (one-time, ~140MB)..." >&2
  mkdir -p "$(dirname "$MODEL")"
  curl -sL -o "$MODEL" "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin"
fi

# Anonymous download first; Instagram sometimes rate-limits, so fall back to Chrome cookies.
if ! yt-dlp -x --audio-format m4a -o "video.%(ext)s" --write-info-json "$URL" >/dev/null 2>&1; then
  echo "Anonymous download failed; retrying with Chrome cookies..." >&2
  yt-dlp --cookies-from-browser chrome -x --audio-format m4a -o "video.%(ext)s" --write-info-json "$URL" >/dev/null 2>&1
fi

ffmpeg -y -loglevel error -i video.m4a -ar 16000 -ac 1 audio.wav
whisper-cli -m "$MODEL" -f audio.wav -otxt -of transcript -np >/dev/null 2>&1

echo "=== METADATA ==="
python3 - <<'EOF'
import json, glob
files = glob.glob('*.info.json')
if files:
    d = json.load(open(files[0]))
    print('uploader:', d.get('uploader') or d.get('channel') or 'unknown')
    print('title:', d.get('title') or '')
    print('duration_sec:', d.get('duration') or 'unknown')
    print('--- caption/description ---')
    print((d.get('description') or '')[:3000])
EOF

echo ""
echo "=== TRANSCRIPT ==="
cat transcript.txt
