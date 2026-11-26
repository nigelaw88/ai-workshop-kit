#!/usr/bin/env bash
# ==============================================================================
# Agentic AI Workshop — macOS & Linux Setup Kit (Zero-Admin, Zero-Xcode)
# Installs:
#   1. OpenCode v2 (standalone binary in ~/.opencode/bin)
#   2. uv + standalone Python 3.12 (in ~/.local/bin — never triggers Xcode CLT)
#   3. ffmpeg (standalone native binary in ~/.local/bin for video/animations)
#   4. Playwright + Chromium (for live browser automation & visual rendering)
#   5. Pre-caches core Python data/PDF/image libraries in uv cache
#   6. Creates ~/Desktop/ai-workshop starter folder + runs Pre-Flight Check
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

OS_NAME="$(uname -s)"
if [ "$OS_NAME" = "Darwin" ]; then
  OS_LABEL="macOS"
else
  OS_LABEL="Linux"
fi

echo ""
echo -e "${BOLD}${CYAN}=====================================================${NC}"
echo -e "${BOLD}${CYAN}   Agentic AI Workshop — ${OS_LABEL} Pre-Flight Setup${NC}"
echo -e "${BOLD}${CYAN}=====================================================${NC}"
echo ""

mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$PATH"

# 1. Install OpenCode v2
echo -e "${BOLD}[1/5] Installing OpenCode...${NC}"
if command -v opencode >/dev/null 2>&1; then
  echo -e "  ${GREEN}Already installed:${NC} $(opencode --version 2>/dev/null || echo 'opencode')"
else
  curl -fsSL https://opencode.ai/v2/install | bash
fi

# 2. Install uv + standalone Python 3.12
echo ""
echo -e "${BOLD}[2/5] Installing uv & standalone Python 3.12...${NC}"
if command -v uv >/dev/null 2>&1; then
  echo -e "  ${GREEN}uv already installed:${NC} $(uv --version)"
else
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$PATH"
uv python install 3.12

# Persist PATH in both ~/.zshrc (macOS default) and ~/.bashrc (Linux default)
for RC_FILE in "$HOME/.zshrc" "$HOME/.bashrc"; do
  touch "$RC_FILE"
  if ! grep -q '\.opencode/bin' "$RC_FILE" 2>/dev/null; then
    echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> "$RC_FILE"
  fi
  if ! grep -q '\.local/bin' "$RC_FILE" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC_FILE"
  fi
done

# 3. Install standalone ffmpeg (zero Admin, zero Homebrew/apt — via PyPI imageio-ffmpeg)
echo ""
echo -e "${BOLD}[3/5] Installing ffmpeg (video & animation engine)...${NC}"
if command -v ffmpeg >/dev/null 2>&1; then
  echo -e "  ${GREEN}ffmpeg already installed:${NC} $(ffmpeg -version 2>/dev/null | head -n 1)"
else
  FFMPEG_SRC=$(uv run --python 3.12 --with imageio-ffmpeg python -c "import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())")
  cp "$FFMPEG_SRC" "$HOME/.local/bin/ffmpeg"
  chmod +x "$HOME/.local/bin/ffmpeg"
  echo -e "  ${GREEN}Installed ffmpeg to:${NC} $HOME/.local/bin/ffmpeg"
fi

# 4. Install Playwright + Chromium (browser automation & motion-graphic rendering)
echo ""
echo -e "${BOLD}[4/5] Installing Playwright & Chromium browser...${NC}"
uv tool install --python 3.12 --force playwright >/dev/null 2>&1 || uv tool install --python 3.12 playwright
playwright install chromium

# 5. Pre-cache core journalism/data Python packages & create workspace folder
echo ""
echo -e "${BOLD}[5/5] Pre-caching data/PDF/image libraries & creating workspace...${NC}"
uv run --python 3.12 \
  --with pandas \
  --with openpyxl \
  --with pypdf \
  --with pillow \
  --with requests \
  --with beautifulsoup4 \
  python -c "import pandas, openpyxl, pypdf, PIL, requests, bs4; print('  Core Python libraries cached OK')"

WORKSHOP_DIR="$HOME/Desktop/ai-workshop"
mkdir -p "$WORKSHOP_DIR"
echo -e "  ${GREEN}Workspace ready:${NC} $WORKSHOP_DIR"

# ==============================================================================
# Pre-Flight Verification
# ==============================================================================
echo ""
echo -e "${BOLD}${CYAN}=====================================================${NC}"
echo -e "${BOLD}${CYAN}               PRE-FLIGHT CHECK SUMMARY${NC}"
echo -e "${BOLD}${CYAN}=====================================================${NC}"

ALL_OK=true

if OPENCODE_VER=$(opencode --version 2>/dev/null); then
  echo -e "  ${GREEN}✅ OpenCode:${NC}   $OPENCODE_VER"
else
  echo -e "  ${RED}❌ OpenCode:${NC}   Not found"
  ALL_OK=false
fi

if UV_VER=$(uv --version 2>/dev/null); then
  echo -e "  ${GREEN}✅ uv:${NC}         $UV_VER"
else
  echo -e "  ${RED}❌ uv:${NC}         Not found"
  ALL_OK=false
fi

if PY_VER=$(uv run --python 3.12 python --version 2>/dev/null); then
  echo -e "  ${GREEN}✅ Python:${NC}     $PY_VER (via uv)"
else
  echo -e "  ${RED}❌ Python:${NC}     Failed to run via uv"
  ALL_OK=false
fi

if FFMPEG_VER=$(ffmpeg -version 2>/dev/null | head -n 1); then
  echo -e "  ${GREEN}✅ ffmpeg:${NC}     ${FFMPEG_VER%% Copyright*}"
else
  echo -e "  ${RED}❌ ffmpeg:${NC}     Not found"
  ALL_OK=false
fi

if PW_VER=$(playwright --version 2>/dev/null); then
  echo -e "  ${GREEN}✅ Playwright:${NC} $PW_VER (+ Chromium)"
else
  echo -e "  ${RED}❌ Playwright:${NC} Not found"
  ALL_OK=false
fi

echo -e "  ${GREEN}✅ Workspace:${NC}  $WORKSHOP_DIR"
echo -e "${BOLD}${CYAN}=====================================================${NC}"

if [ "$ALL_OK" = true ]; then
  echo -e "\n${GREEN}${BOLD}🎉 ALL READY FOR THE WORKSHOP!${NC}"
  echo -e "Please take a screenshot of this summary and send it to the organizer."
  echo -e "${YELLOW}Note: Close and reopen Terminal once before running 'opencode'.${NC}\n"
else
  echo -e "\n${RED}${BOLD}⚠️  Some checks failed.${NC} Please screenshot this output and share it with the organizer.\n"
  exit 1
fi
