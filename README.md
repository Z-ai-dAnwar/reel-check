# reel-check

Paste a short-form video link (Instagram reel, TikTok, YouTube/Short) into Claude Code and get back what actually matters: a transcript, a fact-check of what the video claims, and a straight answer on whether the concept is worth implementing in *your* setup.

Built because every existing tool stops at "here's the text." This one answers the real question: **should I do this, and do I already have it?**

## What it does

1. **Downloads and transcribes locally in ~20 seconds.** yt-dlp pulls the audio (Instagram works anonymously; falls back to your Chrome cookies if rate-limited), whisper.cpp transcribes it on-device. No API keys, no cloud services, no per-use cost. YouTube links use the even faster caption-scrape path.
2. **Extracts the actual claims** - the tools and repos named, the technique described, the "10x" promises.
3. **Verifies before evaluating.** Named repos get web-searched: do they exist, do they do what the video says, or is "link in bio" a sales funnel?
4. **Checks what you already run** - your CLAUDE.md, installed skills, automations - because many "new" concepts are things you already have under a different name.
5. **Gives a verdict:** ALREADY HAVE / IMPLEMENT / PARTIAL / SKIP / JUST INTERESTING, with a concrete plan when it's IMPLEMENT. It never auto-implements; you decide.

## Install

```bash
npx skills add Z-ai-dAnwar/reel-check
```

Or manually: copy this folder to `~/.claude/skills/reel-check/`.

One-time dependencies (macOS):

```bash
brew install yt-dlp ffmpeg whisper-cpp
```

The Whisper model (~140MB) downloads itself on first use.

## Use

Paste a video link into any Claude Code session. That's it - a bare link triggers the skill.

## Notes

- Whisper base.en is the default model: ~5 seconds per minute of audio on Apple Silicon, accurate enough for spoken-word content. Swap the model path in `scripts/fetch-transcript.sh` if you want a bigger one.
- Private accounts and region-locked videos fail after two attempts (anonymous, then Chrome cookies); the skill says so rather than fighting it.
- Downloads land in a temp directory, not your project.

## License

MIT
