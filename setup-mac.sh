#!/usr/bin/env bash
# ==============================================================================
# Agentic AI Workshop — macOS Setup Kit (Zero-Admin, Zero-Xcode)
# Installs:
#   1. OpenCode v2 (standalone binary in ~/.opencode/bin)
#   2. uv + standalone Python 3.12 (in ~/.local/bin — never triggers Xcode CLT)
#   3. Creates ~/Desktop/ai-workshop starter folder
#   4. Runs a Pre-Flight Check you can screenshot for the organizer
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}${CYAN}=====================================================${NC}"
echo -e "${BOLD}${CYAN}   Agentic AI Workshop — macOS Pre-Flight Setup${NC}"
echo -e "${BOLD}${CYAN}=====================================================${NC}"
echo ""

# Ensure user-local paths are on PATH for this session
export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$PATH"

# 1. Install OpenCode v2
echo -e "${BOLD}[1/3] Installing OpenCode...${NC}"
if command -v opencode >/dev/null 2>&1; then
  echo -e "  ${GREEN}Already installed:${NC} $(opencode --version 2>/dev/null || echo 'opencode')"
else
  curl -fsSL https://opencode.ai/v2/install | bash
fi

# 2. Install uv + standalone Python 3.12
echo ""
echo -e "${BOLD}[2/3] Installing uv & standalone Python 3.12...${NC}"
if command -v uv >/dev/null 2>&1; then
  echo -e "  ${GREEN}uv already installed:${NC} $(uv --version)"
else
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$PATH"
uv python install 3.12

# Ensure PATH entries persist in ~/.zshrc (default macOS shell)
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"
if ! grep -q '\.opencode/bin' "$ZSHRC" 2>/dev/null; then
  echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> "$ZSHRC"
fi
if ! grep -q '\.local/bin' "$ZSHRC" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ZSHRC"
fi

# 3. Create clean workshop folder
echo ""
echo -e "${BOLD}[3/3] Creating workshop workspace folder...${NC}"
WORKSHOP_DIR="$HOME/Desktop/ai-workshop"
mkdir -p "$WORKSHOP_DIR"
echo -e "  ${GREEN}Ready:${NC} $WORKSHOP_DIR"

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
  echo -e "  ${GREEN}✅ Python:${NC}     $PY_VER (via uv, no Xcode needed)"
else
  echo -e "  ${RED}❌ Python:${NC}     Failed to run via uv"
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
