---
name: reel-check
description: Transcribe a short-form video (Instagram reel, TikTok, YouTube video/Short) from a URL and evaluate whether the concept in it is real, whether the user already has it, and whether it is worth implementing in their setup. Use this whenever the user pastes an Instagram, TikTok, or YouTube link - even with NO other text, a bare link means "run reel-check on this." Also use when they say things like "check this video," "is this worth doing," "can I use this," or "what does this reel say." For multiple links, run the pipeline once per link.
---

# reel-check

People scroll Instagram and find reels about AI concepts, coding workflows, and GitHub repos. The question is never "what did the video say" - it is "should I actually do this, and do I already have it?" This skill answers that question. The transcript is the input, not the deliverable.

## Requirements (one-time)

```bash
brew install yt-dlp ffmpeg whisper-cpp
```

(On Linux: install the same three via your package manager; whisper.cpp may be packaged as `whisper-cli`.) The Whisper model (~140MB) downloads automatically on first run and is cached at `~/.cache/whisper-cpp/`.

## Step 1: Fetch and transcribe (~20 seconds)

```bash
bash <skill-dir>/scripts/fetch-transcript.sh "<URL>" "<a temp working dir>"
```

Use a temp/scratch directory; keep downloads out of the user's project. The script prints metadata (uploader, caption) and the transcript. Read BOTH - captions often contain the repo name or link the audio never says out loud.

Notes:
- YouTube fast path: YouTube videos usually have captions already, and scraping them beats transcribing. Try `yt-dlp --write-auto-subs --skip-download --sub-format vtt` first; fall back to the script only if no captions exist. Instagram and TikTok have no caption track, so they always go through the script.
- Whisper base.en runs ~5s per minute of audio. A 30-minute YouTube video is fine but tell the user it will take a couple of minutes.
- Whisper mangles technical names ("cloud code" = Claude Code, "Jason L" = JSONL). Silently correct these when quoting.
- If both download attempts fail (private account, region lock), say so and ask the user to share the video another way. Do not fight it beyond the script's two attempts.

## Step 2: Extract the actual claims

From transcript + caption, list concretely:
- What tools/repos/products are named? (exact names, they get web-searched next)
- What is the actual technique or system being described, stripped of the hype framing?
- What claims are made about results? ("saves hours", "10x", etc. - flag these, they are almost never measured)

## Step 3: Verify before evaluating

AI-influencer content is hype-prone; the video's framing is marketing, not documentation. Before any verdict:
- **Named repos/tools:** web-search them. Do they exist? Stars/activity? Does the repo actually do what the video claims? A surprising fraction of these videos describe repos inaccurately or promote the creator's own paid product ("link in bio" = sales funnel signal).
- **Technical claims:** sanity-check against how the underlying system actually works. If the video claims something about a specific tool the user runs (Claude Code, Cursor, etc.), check against that tool's real capabilities, not the video's description of them.

## Step 4: The "already have it" check

This is the highest-value step and the reason this skill exists. Before recommending anything, check what the user already runs:
- Their CLAUDE.md / agent config files (global and project)
- Their installed skills, commands, and hooks
- Their scheduled jobs / automations, if any are documented
- Any memory or notes system the agent maintains for them

Many "new" concepts are things they already have under a different name. Partial overlap is the common case - say precisely which piece is new.

## Step 5: Verdict

Deliver in chat using this structure (short, no filler):

```
**What the video actually says** - 2-4 sentences, hype stripped.
**Real or hype** - verdict on the named tools/claims, with what verification found.
**Do you already have this** - the overlap map against their setup.
**Verdict: ALREADY HAVE / IMPLEMENT / PARTIAL / SKIP / JUST INTERESTING**
**If implementing** - concrete plan sketch: what to build, where it lives, effort estimate, and the trade-off it lives on.
```

Verdict meanings:
- **ALREADY HAVE** - exists in their setup; point at it.
- **IMPLEMENT** - real, useful, missing. Give the plan.
- **PARTIAL** - one piece is worth taking; name it, skip the rest.
- **SKIP** - hype, broken, or not applicable. Say why directly.
- **JUST INTERESTING** - worth knowing, nothing to build.

## Guardrails

- **Never auto-implement.** The verdict is a proposal; the user decides. Challenge the video first, support after it survives verification.
- Do not soften a SKIP. "This is a sales funnel for a paid course" is a complete and useful answer.
