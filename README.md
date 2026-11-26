# Agentic AI Workshop — Pre-Flight Setup Kit (`opencode` + `uv` Python)

A zero-Admin, zero-Xcode setup kit for mixed personal and newsroom-managed laptops (**macOS** & **Windows 10/11**).

- **No Admin rights required** (installs cleanly inside the user's home folder)
- **No Xcode / Homebrew required on macOS** (avoids the 20-minute Xcode Command Line Tools download)
- **No Node.js / Git required** (uses standalone OpenCode v2 binary + `uv` standalone Python 3.12)
- **Takes ~30 seconds** and prints a **Pre-Flight Check Summary** to screenshot 24–48 hours before the workshop.

---

## Participant Pre-Flight Instructions (Copy & Paste)

### macOS
1. Press **`⌘ + Space`**, type **`Terminal`**, and press **Enter**.
2. Paste this single line and press **Enter**:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/nigelaw88/ai-workshop-kit/main/setup-mac.sh | bash
   ```
3. Screenshot the **`PRE-FLIGHT CHECK SUMMARY`** at the end and send it to the organizer.
4. Close and reopen Terminal once before running `opencode`.

### Windows 10 / 11
1. Press the **Windows key**, type **`PowerShell`** (or **`Terminal`**), and open **Windows PowerShell**.
2. Paste this single line and press **Enter**:
   ```powershell
   irm https://raw.githubusercontent.com/nigelaw88/ai-workshop-kit/main/setup-windows.ps1 | iex
   ```
3. Screenshot the **`PRE-FLIGHT CHECK SUMMARY`** at the end and send it to the organizer.
4. Close and reopen PowerShell/Terminal once before running `opencode`.

---

## Workshop Day: Starting OpenCode in the Clean Folder

- **macOS:**
  ```bash
  cd ~/Desktop/ai-workshop && opencode
  ```
- **Windows:**
  ```powershell
  cd "$env:USERPROFILE\Desktop\ai-workshop"; opencode
  ```

> **Why `Desktop/ai-workshop`?** Keeping everyone inside a dedicated folder prevents the AI agent from wandering across their home directory and makes it easy to drag-and-drop sample PDFs, CSVs, and transcripts into the workspace during exercises.

---

## Organizer Checklist Before Workshop Day
1. **Test on Windows & Mac** using the live 1-liners above.
2. **Collect Pre-Flight screenshots** from attendees 24–48 hours ahead of time.
3. **Model / API Key plan:** Decide whether attendees will use a free tier (e.g., OpenCode Zen free models / Google Gemini free tier) or organizer-issued spending-capped workshop keys (e.g., $2–$5 cap per journalist) via `/connect` inside OpenCode.
