# Agentic AI Workshop — Pre-Flight Setup Kit

A zero-Admin, zero-Xcode setup kit for mixed personal and newsroom-managed laptops (**macOS**, **Linux**, & **Windows 10/11**), covering all 6 workshop sessions (intro, workflows, creative/video, browser automation, data, and systems).

### What It Installs (User-Space Only — No Admin, No Xcode, No Homebrew/apt)
- **OpenCode v2** — standalone agentic AI terminal CLI
- **`uv` + Python 3.12** — fast, isolated Python runtime (never triggers macOS Xcode CLT)
- **`ffmpeg`** — standalone native binary for video editing & programmatic `.mp4` animations
- **Playwright + Chromium** — live browser automation & HTML/CSS-to-image/video rendering
- **Pre-cached Python libraries** — `pandas`, `openpyxl`, `pypdf`, `pillow`, `requests`, `beautifulsoup4` (ready offline on conference Wi-Fi)
- **`Desktop/ai-workshop`** — dedicated starter workspace folder

---

## Participant Pre-Flight Instructions (Copy & Paste)

### macOS & Linux
1. Open **Terminal** (`⌘ + Space` → `Terminal` on Mac).
2. Paste this single line and press **Enter**:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/nigelaw88/ai-workshop-kit/main/setup.sh | bash
   ```
3. Screenshot the **`PRE-FLIGHT CHECK SUMMARY`** at the end and send it to the organizer.
4. Close and reopen Terminal once before running `opencode`.

### Windows 10 / 11
1. Press the **Windows key**, type **`Terminal`** *(Windows 11)* or **`Windows PowerShell`** *(Windows 10)*, and press **Enter**. *(Don't use Command Prompt.)*
2. Paste this single line and press **Enter**:
   ```powershell
   irm https://raw.githubusercontent.com/nigelaw88/ai-workshop-kit/main/setup-windows.ps1 | iex
   ```
3. Screenshot the **`PRE-FLIGHT CHECK SUMMARY`** at the end and send it to the organizer.
4. Close and reopen Terminal/PowerShell once before running `opencode`.

---

## Workshop Day: Starting OpenCode in the Clean Folder

- **macOS & Linux:**
  ```bash
  cd ~/Desktop/ai-workshop && opencode
  ```
- **Windows:**
  ```powershell
  cd "$env:USERPROFILE\Desktop\ai-workshop"; opencode
  ```
