# Release notes

## Unreleased

- Expanded the in-app Guide to 103 topics with password/network/file/appearance setup, secure-pin migration and expiry, a visual screenshot-to-note workflow walkthrough, and local AI setup and context review.
- Added an Argon2id/XChaCha20-Poly1305 clipboard vault, master-password unlock, encrypted legacy-pin migration, one-hour pin expiry and session locking, and sensitive clipboard offers.
- Changed the KDE paste queue to an in-memory pipe so secure pins never become plaintext temporary files.
- Added a visual no-code workflow editor, real import-free WASM schedules, and a local screenshot/OCR/translation/note runner.
- Added context-aware local AI with selectable project summaries, open windows and todos, an exact context preview, and explicit Send/Copy/Save actions.

- Added password copying through rbw and KeePassXC CLI, with on-demand unlock, sensitive clipboard metadata, 30-second expiry, and no saved password-query history.
- Added inline ping, DNS, listening-port, routing-table and Wi-Fi scan results with copyable lines.
- Added GPG encryption/decryption, SHA-256 checksums, and confirmed shredding to search and file action menus. Encryption keeps originals and never replaces existing outputs.
- Added local wallpaper cycling and KDE/Spotlight accent commands.
- Fixed content search skipping every match when the searched folder sat under a `build`, `target`, `dist`, `vendor`, or `node_modules` directory, and made the calendar backend, file-manager detection, and login autostart work on systems without `/usr/bin/python3` or `/bin/true`.
- Fixed the image tool checks on systems without the optional gdk-pixbuf WebP loader, where the WebP round-trip is now skipped instead of failing.
- Fixed Nix package inputs, added a dependency lock and WebP loader cache, and kept login startup pointed at the packaged GTK wrapper.
- Kept the content-search result and time limits shared across all searched folders.

## 0.4.0 — 2026-10-20

- Added direct MPRIS music controls and local browser history/bookmark search across Firefox, Chrome, Chromium, and Brave profiles.
- Added screenshot actions and local image/PDF tools for compression, resizing, conversion, text extraction, QR decoding, and color palettes.
- Added Markdown todos, persistent Pomodoro timers with automatic Caffeinate, saved KDE window layouts, and ordered text/image clipboard paste queues.
- Added a Git dashboard, container log streaming and interactive shells, an HTTP scratch client, dotenv comparisons, and dotfiles export with verified private GitHub sync.
- Expanded the built-in Guide to 90 topics and documented setup, dependencies, and command examples. Added browser-data, music, developer-tool, and desktop-workflow regression checks.

## 0.3.0 — 2026-10-18

- Added a permanent Tab actions hint and key binding, opt-in `--autostart` / `--no-autostart` with hidden login startup, and home `.spotlightignore` rules for indexed and recent files. Added strict Clippy CI, native keyboard/startup regression checks, and actual GTK screenshots to the README.

- Added private local-only Ollama summaries, recurrence-aware cached Akonadi meeting availability, configurable aliases/web fallback and root command categories, and a local-catalog Extension Store with verified WASM installs. Expanded the Guide to 78 topics, including login startup, file exclusions, and development checks.
- Added VS Code/JetBrains recent projects, saved project context, SSH aliases in Konsole, environment and dotenv inspection, repository-scoped GitHub PR/issue search, and snippet cursor/clipboard placeholders.
- Added file quick actions, persistent clipboard pins, typed clipboard filters, and confirmed history clearing.
- Added inline IP and system stats, native UTF-8 QR generation, Tesseract OCR, lorem text, case conversion, and JSON formatting.
- Added window close/quit/force-quit actions, local browser tab search, audio output switching, and known Bluetooth device connections.
- Added apt/pacman/Flatpak search with confirmed installs and separate user/system service management.
- Added searchable Guide topics for all new tools, with instructions, examples, requirements, and example buttons. Added isolated CLI, D-Bus, GTK, QR decoding, and OCR regression checks.

## 0.2.0 — 2026-10-17

- Added accent-colored button glow for hover, keyboard focus, and selected states.
- Pinned Search File and Recent above main search results. File results now live in separate views, and Search File carries over the typed query.
- Added calendar event creation from text, with a review form for the title, date, time, duration, location, and destination calendar. Supports GNOME Calendar/Evolution accounts and local-only iCalendar files.
- Expanded calendar search to include Evolution Data Server calendars.
- Expanded the built-in Guide to 46 searchable topics covering every app feature, with examples, shortcuts, requirements, direct navigation, and remembered position.
- Added calendar backend, event form, Guide, and search regression checks.
