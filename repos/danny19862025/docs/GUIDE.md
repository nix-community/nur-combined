# Spotlight — Complete User Guide

Welcome to the complete handbook for **Spotlight**, the native Rust + GTK 4 Linux productivity launcher designed for KDE Plasma on Wayland.

Whether you just installed Spotlight five minutes ago or want to master encrypted clipboard vaults, visual WASM workflows, local Ollama AI, and Git/Docker dashboards, this guide walks you through every feature step by step.

> **Quick Tip:** Inside Spotlight itself, press **`F1`** (or search `guide`) at any time to open the **103-topic built-in Guide** with clickable example buttons.

---

## Table of Contents

1. [Getting Started & Interface Tour](#1-getting-started--interface-tour)
2. [Apps, Files, Recent Items & Content Search](#2-apps-files-recent-items--content-search)
3. [Everyday Utilities (Math, Units, Currency, Language & Emoji)](#3-everyday-utilities)
4. [Quick Notes, Todos, Snippets & Calendar](#4-quick-notes-todos-snippets--calendar)
5. [Clipboard History, Secure Vault & Paste Queue](#5-clipboard-history-secure-vault--paste-queue)
6. [Visual No-Code WASM Workflows](#6-visual-no-code-wasm-workflows)
7. [Context-Aware Local AI (Ollama)](#7-context-aware-local-ai-ollama)
8. [Developer & DevOps Toolkit](#8-developer--devops-toolkit)
9. [Screenshot, Image & PDF Toolkit](#9-screenshot-image--pdf-toolkit)
10. [Desktop, Window, Music & Browser Controls](#10-desktop-window-music--browser-controls)
11. [System, Network, Passwords & File Encryption](#11-system-network-passwords--file-encryption)
12. [Settings, Themes, Aliases, Extension Store & Dotfiles Sync](#12-settings-themes-aliases-extension-store--dotfiles-sync)
13. [Troubleshooting & Uninstall](#13-troubleshooting--uninstall)

---

## 1. Getting Started & Interface Tour

### Launching & Toggling
- On first launch (`~/.local/bin/spotlight`), Spotlight stays running quietly in the background using GTK's lightweight Cairo renderer.
- Press **`Meta+Space`** (after running `spotlight --install-shortcut` on KDE) to show or hide the panel instantly.
- Press **`Escape`** to step back from a sub-view, or press **`Escape`** again to hide the launcher.
- To launch hidden on every login, run `spotlight --autostart`. Remove it anytime with `spotlight --no-autostart`.
- To completely stop the background process, search **Quit Spotlight** or run `spotlight --quit`.

### Anatomy of the Launcher
1. **Top Search Bar:** Type any app name, command, math expression, or URL. Press **`Ctrl+Enter`** to send your query straight to your web search engine.
2. **Header Icons (Top Right):**
   - **Window Manager Grid Icon:** Instant KDE window tiling (halves, quarters, maximize, next monitor).
   - **Gear Icon (`Ctrl+,`):** Opens Settings (General, Window, Theme, Guide, About).
3. **Pinned Buttons (`Search File` & `Recent`):** Always sit right below the search bar so file searches never clutter your main app/command results. Clicking **Search File** automatically carries over whatever text you already typed.
4. **Result List:** Hover with your mouse or use **`↑`/`↓`** to highlight an item. Press **`Enter`** to run/open it, or **`Tab` / `Ctrl+K`** to open the **Actions Menu**.
5. **Footer Bar:** Shows active indicators (such as the **Awake** badge when Caffeinate/Pomodoro is active) and reminds you of **`Open ↵`** and **`Actions Tab`**.

---

## 2. Apps, Files, Recent Items & Content Search

### Launching Applications
- Type any part of an application's name — fuzzy matching handles typos and abbreviations (e.g., `vsc` for Visual Studio Code).
- Press **`Ctrl+F`** on any app to **Favorite** it so it floats to the top. Spotlight also learns from your usage frequency.

### Searching Files & Folders (`Search File`)
- Select the pinned **Search File** button (or type a full path like `~/Documents/report.pdf`).
- Spotlight indexes up to 25,000 entries (6 levels deep) lazily in a background thread and displays live thumbnails for raster images (up to 16 MiB / 16 MP).
- Press **`Enter`** to open folders in your file manager and files in their default app.
- Press **`Tab`** or **`Ctrl+K`** on any file or folder for **File Quick Actions**:
  - **Reveal in Dolphin**
  - **Copy Path** / **Copy File**
  - **Open With...**
  - **Get Info** (exact size, MIME type, path)
  - **Move to Trash** (asks for confirmation)
  - **Image/PDF actions & GPG Vault actions** (automatically shown for matching file types)

### Excluding Folders (`~/.spotlightignore`)
Create `~/.spotlightignore` with standard `.gitignore` syntax to hide private or noisy folders from both **Search File** and **Recent**, then press **`Ctrl+R`**:

```gitignore
/Private/
/Downloads/archive/
*.log
**/cache/
!important.log
```

### Recently Opened Items (`Recent`)
- Select the pinned **Recent** button, or type `recent`, `recent files`, `recent folders`, or `recent report`.
- Reads your real XDG `recently-used.xbel` and KDE `RecentDocuments`, newest first, while automatically hiding dotfiles, missing files, and private entries.

### Searching Inside Files (Content Search)
Requires `ripgrep` (`rg`) on your `PATH`.

| Command | What it searches |
| :--- | :--- |
| `rg rust` or `content rust` | Searches inside files in your home folder |
| `in: notes meeting` | Searches Spotlight Quick Notes, attached Obsidian vault, `~/Notes`, and `~/Documents/Notes` |
| `in: ~/Projects TODO` | Searches inside a specific folder |
| `in: "Documents/My Notes" phrase` | Supports quoted folders with spaces |

Results stream in live with filename, line number, and excerpt. Press **`Enter`** for an inline preview with an **Open in App** button.

---

## 3. Everyday Utilities

### Calculator
Type math directly in the main search bar and press **`Enter`** to copy the result:
- Standard math & parentheses: `(128 * 4) / 3 + 15%`
- Powers & roots: `2^10`, `sqrt(256)`
- Constants & functions: `pi`, `e`, `sin(pi/2)`, `cos(0)`, `ln(10)`, `log(100)`, `abs(-42)`, `round(3.14159)`

### Unit Conversion (Offline)
- Length, weight, data, volume, area, speed, temperature:
  - `10 km to mi`
  - `32 f to c`
  - `2 kg to lb`
  - `1 gib to mib`

### Currency Conversion (Live Daily Rates)
- Type `100 USD to AUD` or `50 eur in gbp`.
- Fetches daily reference rates from [Frankfurter](https://frankfurter.dev/) (only currency codes are sent; amounts stay local; cached 15 minutes). Requires internet + `curl`.

### Dictionary, Offline Translation & Cheat Sheets
- **English Dictionary:** `define serendipity`, `dict ephemeral`, or `dictionary word` (uses Free Dictionary API with 1-hour session cache).
- **Offline Word Translation:** `translate en es cat`, `translate es en gato`, or `offline word` using local `dictd` / FreeDict dictionaries (`dictionaries` lists installed ones). See [OFFLINE.md](OFFLINE.md).
- **Command Cheat Sheets (`tldr`):** `tldr tar` (works offline out of the box!), `tldr git commit`, or `cheat curl`. Press **`Enter`** on the top row to read the full sheet inline, or **`Enter`** on any example to copy it safely (examples are never executed).

### Emoji, Kaomoji & Fonts
- **Emoji:** Search directly by name (`smile`, `rocket`, `heart`) or open **Emoji & Symbols**. Selecting a skin-toned emoji remembers your tone; search **Emoji Skin Tone** to change or reset it.
- **Kaomoji:** Type `kaomoji`, `shrug`, or `table flip`.
- **Fonts:** Type `fonts` or `font JetBrains Mono` to preview any installed system font interactively, copy its name, or apply it directly to Spotlight (**Use in Spotlight** / **Reset Spotlight Font**).

---

## 4. Quick Notes, Todos, Snippets & Calendar

### Quick Notes & Obsidian Auto-Connect
- **Instant one-liner:** Type `note remember to update DNS` and press **`Enter`**.
- **Multiline editor:** Search **Quick Note** (or run `spotlight --quick-note`). Press **`Ctrl+Enter`** to save, or click **Save & Open**.
- **Obsidian Integration:** If Spotlight detects exactly one Obsidian vault, it automatically connects and saves Markdown notes inside `Spotlight Quick Notes/` in that vault (even when Obsidian is closed). Manage this in **Settings → General**.

### Markdown Todos
- `todo add buy milk` (or `todo buy milk`) appends `- [ ] buy milk` to `~/.local/share/spotlight/todos.md`.
- Open tasks appear right in main search — press **`Enter`** to mark one complete!
- `todo` lists open tasks, `todo done` reopens completed tasks, and **Open todos.md** opens the raw Markdown file.

### Snippets & Desktop-Wide Expansion (Espanso)
- Press **`Ctrl+N`** to create a snippet with an optional **Trigger word** (e.g., `;sig`).
- Supports dynamic placeholders: `{cursor}` and `{clipboard}`.
- Inside Spotlight's search bar or Quick Note, type `;sig` followed by **Space** or **Tab** to expand immediately.
- **System-Wide Expansion:** Install [Espanso](https://espanso.org/docs/install/linux/), then search **Enable Desktop Snippet Expansion** (or toggle in Settings). Spotlight syncs only `espanso/match/spotlight.yml` without touching your other Espanso configs.

### Calendar Events, Contacts & Free-Slot Finder
- **Create an event by typing:**
  - `event Birthday on July 13 2027` (all-day event)
  - `add event Dinner on July 13 2027 at 6pm` (timed event)
  - `event on July 13 2027` (pre-fills date and asks for title)
  - Review title, date, time, duration, location, and target calendar (GNOME/Evolution or **Spotlight (local only)**), then press **`Ctrl+Enter`** to save.
- **Search events & contacts:** `calendar Birthday` or `contacts Danny`.
- **Find a free meeting slot:** `meet in 2h` or `meet in 30m for 45m` scans cached Akonadi calendars (requires optional `spotlight-pim` and `spotlight-freebusy` helpers — see [PIM.md](PIM.md)).

---

## 5. Clipboard History, Secure Vault & Paste Queue

### Everyday Clipboard History
- Type `clip` to browse up to 60 text entries and 24 images from KDE Klipper (with image thumbnails and **`Ctrl+K → Preview Image`**).
- Filter by type: `clip text`, `clip images`, or `clip pinned`.
- Clearing Klipper history asks for confirmation and preserves your pins.

### Secure Clipboard Vault (Encrypted Pins)
1. Type `vault` (or `clip vault`) and choose a **master password** on first use.
2. While unlocked, select any text or image in Clipboard History and press **`Ctrl+K → Pin entry`**.
3. **Security guarantees:**
   - Encrypted on disk (`~/.local/share/spotlight/clipboard-vault.json`, mode `0600`) using **Argon2id** + **XChaCha20-Poly1305**.
   - Every pin and unlock session automatically **expires after 1 hour**.
   - Copied pins carry sensitive clipboard metadata and auto-clear from the clipboard after **30 seconds**.
   - Re-open `vault` anytime to lock immediately and wipe the in-memory key.

### Ordered Paste Queue
Need to paste 5 different snippets or screenshots into a form one after another?
1. Type `clip queue` to pick and reorder your pinned text or PNG images.
2. Click **Start paste queue**.
3. Press **`Ctrl+V`** repeatedly in your target app — Spotlight automatically advances to the next item (allow ~150 ms between pastes).
4. Copying anything new or running `clip queue stop` stops the queue. All secure pins stream over an in-memory pipe with zero plaintext temp files.

---

## 6. Visual No-Code WASM Workflows

Build reusable multi-step automations visually — no coding required!

1. Type `workflow` or `workflow new` to open the **Workflow Builder**.
2. Pick a starter template (such as **`Screenshot → OCR → Translate → Save Note`**) or click **Add action** to build your own 1–12 step vertical chain.
3. Available actions:
   - **Input text** — prompt for text in the runner
   - **Clipboard text** — read current clipboard (up to 64 KiB)
   - **Screenshot** — capture via the desktop Screenshot portal
   - **OCR image** — extract text using Tesseract
   - **Translate locally** — translate to your target language using local Ollama
   - **Summarize locally** — summarize using local Ollama
   - **Save note** — save to Quick Notes / Obsidian vault
   - **Copy text** — copy final output to clipboard
4. Click **Save WASM** or **Save & Run**.
5. Run, edit, or delete saved workflows anytime with `workflow run <name>`, `workflow edit <name>`, or `workflow delete <name>`.

> **Under the hood:** Each workflow compiles to a real, import-free binary `.wasm` module (`~/.local/share/spotlight/workflows/`) executed in the Wasmi sandbox with a strict 10,000-fuel budget. See [SECURE_WORKFLOWS.md](SECURE_WORKFLOWS.md).

---

## 7. Context-Aware Local AI (Ollama)

Spotlight's AI features are **100% local-only** — Spotlight actively verifies that Ollama's cloud features are disabled and refuses any non-loopback or redirected endpoint.

### One-Time Setup
1. Install [Ollama](https://ollama.com/) and pull a local text model (e.g., `ollama pull llama3.2`).
2. Start Ollama with cloud disabled:
   ```sh
   OLLAMA_NO_CLOUD=1 ollama serve
   ```
3. (Optional) Choose your preferred model in **Settings → General → Search commands**, or run `ai models` to list installed local models.

### Using Local AI
- **`ai ask what should I focus on next?`** (or just `ai`):
  - Opens a preview showing the **exact** context being included:
    - Selected project summary (from `project ~/Projects/foo`)
    - Open KDE KWin window titles
    - Your local & project `todos.md`
  - Toggle any source on/off, review the text, then click **Send locally**.
  - Explicitly click **Copy answer** or **Save answer as note** — nothing is saved to usage history.
- **`ai summarize clipboard`**: Summarizes your current clipboard text locally in a native preview window.

---

## 8. Developer & DevOps Toolkit

| Command | What it does |
| :--- | :--- |
| `code myproject` | Reopen a recent VS Code / VSCodium / Code OSS folder or workspace |
| `jetbrains myproject` | Reopen a recent JetBrains project (IntelliJ, PyCharm, RustRover, etc.) |
| `projects` | Browse recent projects across all supported editors |
| `project ~/Projects/app` | Set active project context for `gh` and `dotenv` commands |
| `git status` | **Git Dashboard:** scans `~/Projects` and lists all dirty repos with branch & change counts |
| `git spotlight` / `repos` | Fuzzy-search local Git repos & worktrees; open folder or GitHub page |
| `git clone <url>` | Clones HTTPS/SSH repo cleanly into `~/Projects/<repo>` |
| `gh pr list` / `gh issue bug` | Search open PRs and issues in the active project (requires `gh`) |
| `docker` / `podman` | List containers; **`Enter`** starts or stops them |
| `docker logs nginx` / `logs nginx` | Live-tail container logs inside Spotlight (with Stop Tail & Copy Logs) |
| `docker exec nginx` | Open an interactive shell inside a running container |
| `get https://api.github.com/user` | **HTTP Scratch Client:** GET/POST/PUT/PATCH/DELETE with editable headers, body & pretty JSON |
| `dotenv diff` | Compare `.env` vs `.env.example` (missing, extra, and changed keys) |
| `dotenv API` / `env PATH` | Inspect `.env` variables or process environment values |
| `ssh myserver` | Fuzzy-search `~/.ssh/config` aliases and open in Konsole |
| `uuid` | Generate a UUID v4 (`Ctrl+R` for a new one) |
| `hash mytext` / `hash sha512 ...` | SHA-256, SHA-512, SHA-1, or MD5 checksum |
| `base64 encode ...` / `decode ...` | Strict UTF-8 Base64 encoding & decoding |
| `json format {"a":1}` | Pretty-print JSON locally |
| `case snake hello world` | Convert to `camel`, `snake`, or `kebab` case |
| `lorem 5` | Generate placeholder Lorem Ipsum paragraphs |
| `qr hello` | Generate an offline UTF-8 QR code image |
| `ocr` | Extract text from clipboard image or screenshot via Tesseract |

---

## 9. Screenshot, Image & PDF Toolkit

### Interactive Screenshot Capture
- Type `screenshot` to capture via the desktop Screenshot portal.
- Immediately press **`Enter`** to copy the image, or press **`Tab`** for quick actions: **OCR**, **Decode QR**, **Compress**, **Pin to Vault**, or **Save**.

### Local Image & PDF Commands
Paths with spaces work — or omit the path to pick a file interactively! All conversions preserve your original file.

- `compress image 50% ~/Pictures/photo.png` — Saves quality-50 WebP
- `resize 1080p ~/Pictures/photo.png` — Fits inside 1920×1080 without upscaling
- `image to webp ~/Pictures/photo.png` — Converts to WebP
- `palette ~/Pictures/photo.png` — Extracts up to 5 dominant colors with one-click copy buttons
- `pdf text ~/Documents/report.pdf` — Extracts readable text from a PDF

---

## 10. Desktop, Window, Music & Browser Controls

### Windows, Virtual Desktops & Saved Layouts (KDE KWin)
- `window chrome` — Focus any open window across desktops/activities.
- `desktop` / `desktop 2` — Switch KWin virtual desktops.
- `switch` — Search windows and virtual desktops together.
- `close window`, `quit app`, `kill window` — Targeted window management (quit/force-quit confirm first).
- **Window Manager** (grid icon in top-right): Tile left/right/quarters, maximize, restore, minimize, or move to next monitor. Click **Customize Shortcuts** to bind KDE keys.
- **Saved Window Layouts:**
  - `layout save work` — Saves all current window positions.
  - `layout work` (or `layout restore work`) — Restores open windows to their saved spots.
  - `layout` / `layout delete work` — List or delete layouts.

### Timers, Alarms, Pomodoro & Caffeinate
- `timer 5m`, `set timer for 30 seconds`, `timer 1h30m` — Starts a countdown (type `timer` alone for a visual picker).
- `alarm 7:30 am`, `alarm 18:45`, `alarm in 5 minutes` — Schedules a local alarm (type `alarm` alone for a picker with **Test Sound**).
- `cancel timer` / `cancel alarm` — Cancel active reminders.
- `pomodoro 25m` (or `pomodoro`) — Starts a focus timer and **automatically enables Caffeinate** until finished (survives restarts!).
- `caffeinate` / `keep awake` — Manually prevent screen dimming, locking, and sleep while Spotlight runs.

### Color Picker & Screen Ruler
- **Color Picker (`color picker`, `eyedropper`):** Click any pixel on screen to copy `#RRGGBB`, then pick HEX, RGB, RGBA, HSL, HSLA, or HSV from **Color Formats**.
- **Screen Ruler (`measure`, `ruler`):** Drag across a frozen screen capture to measure width, height, and diagonal distance in pixels across multi-monitor setups (`Ctrl+C` copies).

### Music & Local Browsers
- **Music (MPRIS D-Bus):** `music`, `pause`, `next track`, or `play lofi` (opens YouTube search).
- **Browser History, Bookmarks & Tabs:** `history youtube`, `bookmark github`, and `tabs chrome` across Firefox, Chrome, Chromium, and Brave.

### Audio, Wireless & Appearance
- `volume up` / `volume down` / `speaker mute` / `mic up` / `mic down` / `mic mute` (WirePlumber `wpctl`)
- `speakers` — List and switch audio output devices
- `wifi`, `bluetooth`, `bluetooth devices`, `bluetooth connect AirPods`
- `dnd` / `do not disturb` — Toggle KDE notification popups
- `dark mode` — Toggle KDE light/dark color scheme
- `wallpaper next` — Cycle local wallpapers
- `accent blue` — Update KDE and Spotlight accent color
- `empty trash` — Empties KDE Trash after confirmation

---

## 11. System, Network, Passwords & File Encryption

- **System Stats:** `ip` / `my ip` / `ip local`, `battery`, `disk`, `ram`, `uptime`.
- **Network Diagnostics:** `ping 8.8.8.8`, `dig github.com`, `my ports`, `my routes`, `scan wifi` — all show copyable inline reports.
- **Process Killer:** `kill firefox` or `kill 12345` — pins your own process safely via Linux `pidfd` and sends `SIGTERM`.
- **Packages & Services:** `apt search`, `pacman Ss`, `flatpak search` (reviewed install); `service status` (user services); `systemctl restart docker` (reviewed system action).
- **Password Manager (`pass github`):** Copies via `rbw` (Bitwarden) or `KeePassXC` (`keepass setup`), with sensitive clipboard metadata, 30-second expiry, and zero saved query history.
- **GPG File Vault & Shredder:** `encrypt file`, `decrypt file`, `checksum file`, and `shred file` (confirmed). Originals are always preserved during encryption.

---

## 12. Settings, Themes, Aliases, Extension Store & Dotfiles Sync

Press **`Ctrl+,`** to open Settings:

- **General:**
  - **Custom Aliases:** Define shortcuts like `ff = firefox`, `g = web {query}`, or `prs = gh pr list {query}`.
  - **Web Fallback Engine:** Choose Google, DuckDuckGo, Bing, Brave, or Disabled.
  - **Root Command Categories:** Toggle off categories you don't use to keep search fast and clean.
  - **Local AI Model & Obsidian Vault:** Pick your default Ollama model and manage Quick Note storage.
  - **Dotfiles Sync:** Point to an existing Git clone to export snippets, notes, and quicklinks to `spotlight/export.json` (`0600`). **Sync private repo** verifies via `gh` that your GitHub repo is strictly **private** before pushing.
- **Window:** Switch between **Compact** and **Expanded** layouts and four UI scales (`90%–125%`).
- **Theme:** Pick **Dark**, **Light**, or **Midnight** presets, or customize background, text, accent, and selection hex colors with live preview and accent-colored button glow.
- **WASM Extension Store (`store`):** Browse `community-plugins.toml`, inspect capabilities and SHA-256 hashes, and install sandboxed WASM plugins (`plugin <id> <query>`). See [WASM.md](WASM.md).
- **Script Commands:** Place any executable script with a shebang in `~/.local/share/spotlight/scripts/`.

---

## 13. Troubleshooting & Uninstall

- **Shortcut doesn't open Spotlight on KDE:** Run `~/.local/bin/spotlight --install-shortcut`, or check **KDE System Settings → Keyboard → Shortcuts → Spotlight**.
- **Clipboard history is empty:** Make sure KDE Klipper is enabled in your Plasma system tray.
- **Content search (`rg`) says not found:** Install `ripgrep` from your distro's package manager.
- **Local AI refuses to connect:** Ensure Ollama is running locally with `OLLAMA_NO_CLOUD=1 ollama serve` on `127.0.0.1:11434`.
- **Diagnostics:** Run `spotlight --diagnostics` in a terminal to inspect memory usage.

### Uninstall
```sh
spotlight --no-autostart
rm -rf ~/.local/bin/spotlight \
       ~/.local/lib/spotlight \
       ~/.local/share/applications/spotlight.desktop \
       ~/.local/share/kglobalaccel/spotlight.desktop \
       ~/.local/share/icons/hicolor/scalable/apps/spotlight.svg
```
Your notes, snippets, and data remain safe in `~/.local/share/spotlight` until you remove that folder manually.
