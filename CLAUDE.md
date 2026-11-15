# ghost-editor (cloud fork)

This repo IS the ghost-editor skill. Follow `SKILL.md` when the user hands over a talking-head video.
`$S` = `~/.claude/skills/ghost-editor`, a symlink to this checkout made by `scripts/cloud_setup.sh`.
If the symlink is missing, run `bash scripts/cloud_setup.sh` once.

## Running in a Claude Code cloud session (Linux, CPU only)
- The user is on Windows / phone and talks Vietnamese: answer in Vietnamese.
- Input video: the user attaches it in chat or sends a Google Drive link (drive.google.com is allowed).
  Put each reel project in its own folder under `~/reels/<name>/`.
- Output: copy the finished MP4 into this checkout's `out/` folder (gitignored) and send it with SendUserFile,
  and remind the user to download it: the container is deleted when the session ends.
- macOS-only parts degrade on Linux: the caption OCR check in `broll_qa.py` is skipped (macOS Vision);
  `--backend mlx` transcription is Apple-only, use the default whisper backend (`--model turbo`, CPU).
- Rendering is CPU-only and slower than on an M-series Mac; run long renders in one blocking call.
- Node's fetch ignores the proxy by default, so the proxy cannot put the real Gemini key on Node calls
  (`ai-tag.mjs`, used by `build.mjs` for `ai: true` captions). Run Node with the flag: `node --use-env-proxy $S/scripts/build.mjs $P`.
  (The env var NODE_USE_ENV_PROXY=1 does the same but a session cannot set it; the user can add it in the environment's Settings.)
- Gemini checks (B-roll people/line checks) need a Gemini key on this environment: if `doctor.sh` says the key
  is missing, ask for it with request_credential for host generativelanguage.googleapis.com, header x-goog-api-key.
- Never commit user videos or renders to this repo.
