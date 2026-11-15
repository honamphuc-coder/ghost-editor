#!/bin/bash
# Set up ghost-editor in a Claude Code cloud session (Linux). Called from the environment's setup script:
#   bash ghost-editor/scripts/cloud_setup.sh || true
# Idempotent; network errors never stop the session from starting (no set -e).
S="$(cd "$(dirname "$0")/.." && pwd)"
log() { echo "[ghost-editor setup] $*"; }

# SKILL.md uses ~/.claude/skills/ghost-editor as $S: point it at this checkout so the skill loads and paths resolve
mkdir -p "$HOME/.claude/skills" && ln -sfn "$S" "$HOME/.claude/skills/ghost-editor"

# CPU-only torch is much smaller; needs download.pytorch.org allowed. Falls back to PyPI torch via openai-whisper.
python3 -c "import torch" 2>/dev/null || \
  timeout 600 pip install -q torch --index-url https://download.pytorch.org/whl/cpu 2>/dev/null || log "CPU torch not available, PyPI torch will be used"
timeout 1200 pip install -q openai-whisper numpy opencv-python-headless pillow google-genai yt-dlp || log "WARN pip install failed"

# HyperFrames renderer (version pinned in scripts/HF_VERSION), cached by npx
timeout 600 bash "$S/scripts/hf.sh" --version >/dev/null 2>&1 || log "WARN HyperFrames not fetched"

# Music and SFX (Mixkit), then Fluent emoji (GitHub, optional: emoji beats fall back to the font glyph); existing files kept
timeout 900 python3 -I "$S/scripts/library_restore.py" --licensed-only --music-only || log "WARN music incomplete"
timeout 900 python3 -I "$S/scripts/library_restore.py" --licensed-only --sfx-only || log "WARN sfx incomplete"
timeout 300 python3 -I "$S/scripts/library_restore.py" --emoji-only || log "WARN emoji incomplete (optional)"

# Whisper turbo weights (needs openaipublic.azureedge.net allowed); otherwise the first transcription fetches them
timeout 900 python3 -c "import whisper; whisper.load_model('turbo', device='cpu')" >/dev/null 2>&1 || log "WARN whisper turbo weights not fetched"

log "done"
