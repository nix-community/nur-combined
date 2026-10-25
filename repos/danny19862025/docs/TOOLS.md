# Expanded tools and desktop actions

## Local AI, availability, and search preferences

`ai` or `ai ask …` opens a context-aware local AI dialog with source selection and a preview of the selected project, open window titles, and todos. No model request is made until Send locally. See [secure workflows and context AI](SECURE_WORKFLOWS.md).

`ai summarize clipboard` prepares a local-only action. Enter reads text from the current clipboard (up to 64 KiB), verifies the local Ollama server and model, then generates a summary in a native window with Copy summary. Closing the window cancels the request. `ai models` lists installed local models; Settings → General → Search commands has an optional model name. Blank selects the first installed local model. Spotlight does not install, pull, or start models, save prompts/responses, or use a cloud fallback.

Install Ollama and a local text model yourself, then start the server with **`OLLAMA_NO_CLOUD=1`**. Spotlight requires `/api/status` to report `cloud.disabled = true`, rejects remote model metadata, and verifies local model weights before sending clipboard text. The client uses only `127.0.0.1:11434`, ignores proxy settings and `OLLAMA_HOST`, and refuses redirects. `SPOTLIGHT_OLLAMA_PORT` selects another numeric loopback port. Older servers without verifiable local-only status are refused. See [Ollama's local-only configuration](https://docs.ollama.com/faq#how-do-i-disable-ollamas-cloud-features).

`meet in 2h` finds a 30-minute slot at least two hours from now. `meet in 30m for 45m` selects another offset and duration. Compact `m`, `h`, and `d` durations are supported, with offsets up to seven days and meetings of 5 minutes to 8 hours. The initial search time rounds up to the next five minutes; availability covers all hours of the next seven days. Enter previews start/end times for copying and does not create an event.

Meeting availability reads **cached Akonadi calendar data**, not attendee availability or unsynchronized remote changes. Open KOrganizer to synchronize first. The optional public-API `spotlight-pim` bridge and `spotlight-freebusy` libical helper are required. Recurrence, EXDATE/EXRULE exclusions, moved/cancelled instances, transparency, floating/zoned times, and all-day dates are handled by libical and the bridge. Unsupported recurrence ranges, RDATE periods, unresolved timezones, malformed records, or data limits produce an error rather than a guessed free slot. See [calendar setup and bounds](PIM.md).

In **Settings → General → Search commands**, aliases use `name = target`, one per line:

```text
ff = firefox
g = web {query}
prs = gh pr list {query}
```

Aliases expand complete first words, retain the text in the search box, and resolve before command dispatch. `{query}` inserts the following text; without it, following text is appended. Targets are Spotlight searches, never shell snippets. Names are case-insensitive, with at most 64 aliases, eight expansion steps, and no cycles. The default `g` alias uses web search. Choose Google, DuckDuckGo, Bing, Brave, or Disabled as the fallback engine; the web result and Ctrl+Enter use that choice. Apply search settings validates and saves the draft.

Category checkboxes in the same panel remove unused tools from root search and gate typed lookups before backend dispatch. Docker/Podman commands, for example, do not start a CLI lookup while disabled. Disabled Fonts/Emoji skip constructing their main-search results. Changes clear cached command results and cancel active content/extension searches. App search, Settings, and the Guide remain available, and saved data is kept. These settings customize root search; a view opened explicitly from the Guide remains usable.

## Extension Store

`store` browses the local TOML catalog; `store text` filters it. Enter opens details showing version, author, source, artifact, sandbox capabilities, and SHA-256. **Install plugin** is the reviewed installation action. The initial catalog includes the bundled Text Tools SDK example, available offline. There is no invented list of third-party plugins or registry service.

The source catalog is [`community-plugins.toml`](community-plugins.toml), bundled into the app and also installed beside the binary. To customize it without rebuilding, copy it to `$XDG_DATA_HOME/spotlight/community-plugins.toml` (normally `~/.local/share/spotlight/community-plugins.toml`) and press Ctrl+R after editing. Add compatible community modules with an immutable `https://github.com/OWNER/REPO/releases/download/TAG/ASSET.wasm` artifact URL, a GitHub source URL, and the exact module SHA-256. The catalog supports at most 100 entries and 256 KiB; Python 3.11+ parses TOML locally.

No request is made when browsing the catalog. Release downloads occur after Install, use HTTPS GitHub release/asset hosts, and are capped at 4 MiB. Spotlight validates the digest, WASM structure, ABI exports, and imports before publishing a private plugin directory atomically. Modules may import only Spotlight's three WASM host functions. Native scripts/installers and archives are not accepted. Existing plugin IDs are never overwritten; this first Store does not perform upgrades or removals. Installed plugins appear in Script Commands and `plugin <id> <query>` and run inside the existing Wasmi capability boundary. See [WASM ABI and limits](WASM.md).

`python3 tests/productivity_smoke.py` checks local-only status, cloud/remote/redirect refusal before prompts, proxy bypass, native AI/settings/store flows, aliases and disabled dispatch, synthetic Akonadi cache handling, real libical recurrence/timezones, checksum failures, duplicate preservation, and execution of an installed example in the real WASM sandbox. AI and Akonadi use private fixtures; no model, account, or remote calendar is needed.

## Git status dashboard, live container logs and HTTP scratch

`git status` scans `~/Projects` for repositories and worktrees, then shows dirty repositories in one list with branch and change counts. Append a repository-name fragment to filter. Enter previews changed paths and offers Open for the repository folder. It includes staged, unstaged, untracked and conflict entries. Clean repositories are counted but omitted from the list. Scanning avoids optional Git index locks and never stages changes. It skips symlinked directories and `.git`, `target`, `node_modules`, `vendor`, `__pycache__`, `build` and `dist`; a 100,000-directory / 30-second cap is reported when reached. Ctrl+R refreshes.

`docker logs nginx`, `podman logs nginx` and the short form `logs nginx` find containers and open an in-app live log viewer. It shows the latest 200 lines plus new stdout/stderr with timestamps. **Stop Tail** stops the CLI; **Close** also kills and reaps it. The visible buffer keeps its most recent 1 MiB. **Copy Logs** copies the visible text. Logs can also be inspected for stopped containers.

`docker exec nginx` opens an interactive `sh` in a running container. Use `docker exec nginx -- /bin/bash` or `podman exec nginx -- sh -lc 'your command'` for another executable. Commands are tokenized and passed as arguments, with no host shell interpolation. Requires the engine CLI, permission to use its engine, and Konsole, GNOME Terminal or xterm. Existing start/stop queries still work.

`get https://api.github.com/user` or `http` opens **HTTP Scratch**. Select GET, POST, PUT, PATCH, DELETE, HEAD or OPTIONS; edit the URL, one `Header: value` per line, and an optional body, then press **Send**. It uses local curl and the requested HTTP(S) endpoint directly. Headers, body and response stay in the window and are never saved into usage history. Authentication must be entered explicitly in the headers field; Spotlight does not read `.curlrc`, browser cookies or netrc credentials. Responses include status, elapsed time, headers and text, with pretty-printed JSON where possible. HTTP 4xx/5xx bodies are displayed. Redirects are shown without automatically following them. Requests time out after 20 seconds; response bodies are limited to 1 MiB. **Copy Response** copies the result.

`dotenv diff` compares the current project’s `.env` and `.env.example`; `dotenv diff .env.local .env.example` chooses another pair. Quoted paths and spaces work. Results list missing keys, extra keys and different values. Matching keys are omitted. Values are loaded only into the comparison preview when you select a key. Files are parsed as literal dotenv text and never sourced. Choose a project with `project /path/to/project` first, or pass absolute paths.

## Dotfiles export and private sync

Settings → General → **Dotfiles sync** accepts the root folder of an existing Git clone. **Export and commit** writes a private (0600) `spotlight/export.json` containing a schema version, snippets, saved notes, quick-note Markdown content and quicklinks. Usage history, clipboard pins, environment values and other settings are excluded. Missing quick-note source files stop export before any destination write. The export directory/file cannot be symlinks.

Only the export file is staged and committed; unrelated staged files stay staged and are not included. An unchanged export does not create another commit. Configure your normal Git author identity in the destination repo. The repository folder is remembered in Spotlight settings. Export is manual; there is no background sync or import.

**Sync private repo** exports and commits, then pushes `origin HEAD` without force. It requires one GitHub origin push URL and an authenticated `gh` CLI. Spotlight checks the actual push destination with `gh repo view --json isPrivate` before export and again before pushing, and refuses public or unverified repositories. This works with HTTPS and SSH GitHub URLs. For another Git host, use local export and your existing private-repository push workflow.

`/usr/bin/python3 tests/devkit_smoke.py` checks the real GTK HTTP client against a local server, fixture container discovery and exact terminal arguments, live tail cancellation/reaping, export controls and private/public origin checks. It uses isolated home/data directories and fake engine/GitHub CLIs; it never executes in your containers or pushes personal data. Rust tests also verify HTTP error responses, literal request bodies, Git index preservation and unrelated staged-file isolation.

## Developer workflow

| Command | Behavior |
| --- | --- |
| `code myproject` | Reopen a recent local VS Code folder or `.code-workspace` |
| `jetbrains myproject`, `pycharm myproject` | Reopen a recent JetBrains project in its original IDE |
| `projects` | Browse recent projects from both editor families |
| `project ~/Projects/myproject` | Choose a folder as context for GitHub and dotenv commands |
| `ssh myserver` | Find a configured SSH alias and open Konsole running SSH |
| `env PATH`, `environment` | Search Spotlight's process environment by variable name; Enter inspects a value |
| `dotenv API` | Inspect matching variables from the current project's `.env` |
| `dotenv "/home/me/My Project/.env.local" TOKEN` | Inspect an explicit dotenv file with an optional name filter |
| `gh pr list review:required` | Search open pull requests in the current project |
| `gh issue bug`, `gh issue list --search "label:bug"` | Search open issues in the current project |
| `gh pr list --repo owner/repository` | Override context with a GitHub repository |
| `gh issue --repo "/home/me/My Project"` | Override context with a local Git repository |

Recent-project discovery uses **Python 3's standard library**. It reads `User/globalStorage/storage.json` and the relevant history keys in `state.vscdb` using a read-only SQLite connection for Code, Code Insiders, VSCodium, and Code OSS under `$XDG_CONFIG_HOME` (normally `~/.config`). JetBrains discovery reads `JetBrains/*/options/recentProjects.xml`, `recentSolutions.xml`, and legacy IDE configuration folders. Missing projects and remote workspace URIs are skipped. Opening a project uses its editor's command-line launcher, with an installed desktop entry as a fallback. See [VS Code's CLI documentation](https://code.visualstudio.com/docs/configure/command-line).

Opening an editor project updates the saved context. `project` displays that context and lets you choose another recent project; an absolute folder path also works without editor history. `SPOTLIGHT_PROJECT_DIR` in Spotlight's launch environment overrides saved context. The fallback is Spotlight's working directory. GitHub commands verify Git repository context and show the repository or folder with results. They require an installed, authenticated **GitHub CLI** and internet access. Listing uses structured JSON with a 40-result limit, and Enter opens the selected URL in the browser. Search text is passed as one argument to `--search`. See [gh pr list](https://cli.github.com/manual/gh_pr_list) and [gh issue list](https://cli.github.com/manual/gh_issue_list).

SSH search reads `~/.ssh/config` and bounded recursive `Include` files, supporting quoted paths and `*`/`?` globs. Only literal named Host aliases appear; wildcard and negated patterns are omitted. Discovery does not run config commands. Selection validates the alias again and runs `konsole --separate -e ssh -- ALIAS` with separate arguments. Konsole and OpenSSH must be installed. SSH handles authentication, host-key review, and the rest of your configuration in the terminal.

The environment inspector shows **variable names** in results and reads values on selection. Values are not placed in Spotlight's saved usage data or command cache. The environment belongs to the launcher process; another terminal's later `export` does not alter it. Dotenv inspection reads the file locally without sourcing or executing it, with a 1 MiB limit. It supports optional `export`, comments, empty values, quoted/multiline values, and last-key-wins duplicates. `${VARIABLE}` and `$(command)` remain literal. Parse errors identify the line without echoing its value. Dotenv inspection does not modify the file or process environment.

### Snippet placeholders

Snippet values accept `{cursor}` and `{clipboard}`. For example, `Hello {clipboard}, {cursor}!` inserts the current clipboard text and places the caret before `!` when the trigger expands on Space or Tab. The first cursor marker sets the position; further cursor markers are removed. Clipboard text is inserted literally, so placeholders inside it are not expanded again. Clipboard text is read at expansion time and limited to 1 MiB; edits made while that asynchronous read is pending cancel the insertion.

Selecting a snippet with Enter copies resolved text, with cursor markers removed. Trigger expansion controls the caret in Spotlight; a copied plain string carries no caret position. Desktop expansion exports Espanso's [cursor hints](https://espanso.org/docs/matches/basics/#cursor-hints) and [clipboard extension](https://espanso.org/docs/matches/extensions/#clipboard-extension), while preserving literal code braces through echo variables. Clipboard placeholders use text; an empty or image-only clipboard supplies empty text.

`python3 tests/devtools_smoke.py` checks real SQLite and XML editor fixtures, SSH Includes and stale aliases, exact editor/SSH/GitHub arguments, dotenv parsing, repository context, private inspector results, and native GTK snippet caret/clipboard behavior. External editor, SSH, and GitHub programs use fixtures; no connection or GitHub request is made.

## File and system tools

Select a file in **Search File** or **Recent**, then press **Ctrl+K** for Reveal in Dolphin, Copy Path, Move to Trash, Copy File, Open With, and Get Info. Trash requires confirmation. Copy File supplies the standard file-manager clipboard formats; paste it into Dolphin to copy the file. Get Info includes MIME type, size in bytes, and modification time. Directory size describes the directory entry rather than recursively adding its contents.

| Command | Behavior |
| --- | --- |
| `ip`, `my ip` | Local addresses and a public IP lookup through ipify |
| `ip local` | Local addresses only |
| `battery`, `disk`, `ram`, `uptime` | Copyable system snapshots; Ctrl+R refreshes |
| `qr hello`, `qr https://example.com` | Offline UTF-8 QR generation; Enter previews; Copy Image copies it |
| `generate qr` | Enter opens a text/URL input and Generate previews the QR |
| `ocr` | Choose clipboard-image or latest-screenshot recognition |
| `ocr latest`, `ocr /path/to/image.png` | Extract text and show a copyable preview |
| `lorem 5` | Generate five placeholder paragraphs, up to twenty |
| `case camel Hello world` | `helloWorld`; also snake, kebab, pascal, upper, lower, title |
| `json format {"ready":true}` | Validate JSON and open a formatted preview |
| `clip text`, `clip images`, `clip pinned` | Open filtered clipboard history |
| `speakers`, `speakers HDMI`, `audio outputs` | Select an audio output |
| `close window Firefox` | Request a normal close through KWin |
| `quit app Firefox` | Confirm closing all windows sharing the selected application process |
| `kill window Firefox` | Confirm force-quitting its process; unsaved work can be lost |
| `tabs chrome project` | Find titles and URLs in a connected local browser |
| `apt search firefox`, `pacman Ss firefox`, `flatpak search firefox` | Search and review a package installation |
| `packages firefox` | Select the available package manager automatically |
| `service status`, `service restart demo` | List/status or confirmed user service actions |
| `systemctl restart docker` | Review a system service restart |
| `systemctl --user stop demo` | Review stopping a user service |
| `bluetooth devices`, `bluetooth connect AirPods` | List known devices or select one to connect |
| `bluetooth disconnect Keyboard` | Select a known device to disconnect |

## Requirements

QR, case conversion, lorem generation, JSON formatting, RAM, uptime, disk, and battery discovery run locally. QR generation uses the bundled Rust `qrcodegen` dependency; no QR command-line utility is needed. IP discovery uses `ip`, and public IP uses `curl` and an internet connection.

OCR requires **Tesseract** and its installed language data. It uses the installation's default language. Inputs are limited to 16 MiB and 16 million pixels. Screenshot discovery checks `Pictures/Screenshots`, `Pictures/screenshots`, `~/Screenshots`, and screenshot/spectacle filenames in Pictures. An explicit path works for another folder. Clipboard OCR reads an existing image, and screenshot OCR reads an existing capture.

Audio outputs use `pactl` when available and move active streams to the selected sink. `wpctl` is the fallback for changing the default output for new streams. Devices are validated again before switching. Bluetooth device connections use `bluetoothctl`; pair devices in desktop Bluetooth settings before connecting them from Spotlight.

File Trash uses GIO's desktop Trash support, which may reject unsupported/internal mounts. Reveal prefers Dolphin and falls back to the desktop FileManager1 service. Open With uses the native GTK application chooser, compatible with GTK 4.10.

## Clipboard pins

In Clipboard History, **Ctrl+K** offers Pin entry, Unpin entry, filters, and Clear clipboard history. Text and image pins are saved under Spotlight's private data directory. Image pins are copies, so deleting the original Klipper history does not remove them. Unpinning an image removes Spotlight's copy. There is a fifty-entry limit; individual pinned text and images are limited to 64 KiB and 16 MiB respectively.

Clear history confirms before calling Klipper's supported clear-history and clear-contents methods. Spotlight's pins are retained. Spotlight does not edit Klipper's database directly.

## Music, browser pages, screenshots and local files

`music` lists MPRIS players with title, artist, playback status and per-player Play/Pause, Play, Pause, Next, Previous and Stop actions. `pause`, `next track`, `previous track`, `play` and `stop` narrow the controls. These use MPRIS directly over session D-Bus, require no `playerctl`, respect player capabilities, and target the selected player. `play lofi` opens a clearly labelled YouTube search; MPRIS has no generic catalog-search API, so you choose a result in the browser. Browsing the result list does not change playback.

`history youtube` and `bookmark github` search Firefox `places.sqlite`, Chrome/Chromium/Brave `History` databases and Chromium-family `Bookmarks` JSON, including multiple normal profiles, standard Firefox/Chrome Flatpak locations and Firefox/Chromium Snap locations. Only HTTP(S) pages are offered. Enter opens the selected URL in the default browser. Python 3 and its standard SQLite library are required.

Profiles are never written. Each lookup copies a stable database/WAL pair into a private temporary directory, queries that snapshot in SQLite read-only mode, then deletes it. This includes uncheckpointed visits while avoiding writes to the live profile's shared-memory read marks. A changing profile is retried; unreadable profiles produce a message while other profiles still return results. Snapshots are limited to 512 MiB per profile, query output to 80 unique URLs. See [SQLite WAL behavior](https://www.sqlite.org/wal.html).

`tabs chrome` also works without debugging: it offers **History** results from Chrome/Chromium. These are recent pages and open URLs; they are not a list of currently open tabs. To activate live Chrome-family tabs instead, explicitly set `SPOTLIGHT_CHROME_DEBUG_PORT` for an existing loopback-only endpoint in a dedicated browser profile. Spotlight then queries `http://127.0.0.1:PORT/json/list` and activates selected targets. If the endpoint is unavailable, it returns recent pages. See [Chrome's remote-debugging changes](https://developer.chrome.com/blog/remote-debugging-port).

`screenshot` or **Take Screenshot** hides Spotlight and requests an interactive capture through the desktop Screenshot portal. The preview keeps one capture and offers **Copy Image**. Press **Tab** or **Ctrl+K** for **OCR** (Tesseract), **Decode QR** (`zbarimg`), **Compress** (quality-50 WebP using vips or ffmpeg), **Pin** (Spotlight clipboard pins), and **Save…** (PNG file picker). Each action reuses the captured image. Compression asks for a local destination and keeps the capture available for the next action. Cancel returns to Spotlight. The portal's temporary capture is removed after loading. OCR and QR results open a text preview with Copy; decoded content is never automatically opened or executed.

| Command | Result |
| --- | --- |
| `compress image 50% [path]` | Quality-50 WebP; the resulting byte size depends on the image |
| `resize 1080p [path]` | PNG fitting inside 1920 × 1080, preserving aspect ratio and avoiding upscaling |
| `image to webp [path]` | Quality-80 WebP |
| `pdf text [path]` | Local `pdftotext -layout` extraction in a copyable preview; up to 1 MiB |
| `palette [path]` or `color palette [path]` | Up to five dominant opaque colors with hex swatches, individual Copy and Copy All |

Omit a path to use the file picker; quoted paths, `~/` and spaces work. Ctrl+K on an image or PDF offers the corresponding tools. Image conversions prefer `vips`, falling back to `ffmpeg` with its WebP encoder. Files are limited to 80 million pixels. A private work directory holds conversion output; the finished file is saved beside its original with an unused filename and 0600 permissions. Existing files are never replaced. Palette extraction runs locally through the installed image decoder, ignores transparent pixels, and can yield fewer colors for flat images. Copying one palette color also makes it available in Spotlight's Color Formats view.

## Packages and services

Package searches read existing package catalogs and configured Flatpak remotes. Selecting a result opens a confirmation that names the package, manager, remote where relevant, and installation scope. Required dependencies can also be installed. apt/pacman invoke `pkexec` and the desktop authorization agent. Flatpak prefers a configured user remote of the selected name and otherwise uses the system installation with its normal authorization. Database refreshes, upgrades of the whole system, and adding remotes remain separate administrator tasks.

`service` and `services` default to **user** scope. `systemctl` defaults to **system** scope, matching the CLI; `--user` and `--system` select it explicitly. Status is read-only. Start, restart, and stop ask for confirmation and accept service units only. System actions use desktop authorization; user actions run through `systemctl --user`. The list includes loaded service units, including inactive loaded units. See [systemctl](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html).

Normal window closing uses the [KWin scripting API](https://develop.kde.org/docs/plasma/kwin/api/). Force quit verifies the selected window and its process identity, then uses a Linux pidfd to avoid signaling a reused PID. Only a process owned by the current user can be force-quit.

## Verification

`cargo test --offline` checks parsers, text vectors, identity validation, and compatibility with older saved data. `python3 tests/features_smoke.py --ui` runs the fixture-backed backend and real GTK checks in a private D-Bus session. It independently decodes a generated Unicode QR code when `zbarimg` is installed and runs real Tesseract OCR. Package installs, service actions, audio switching, Bluetooth connections, and clipboard clearing use fixtures. Trash checks use disposable files and an isolated Trash directory.

On KDE, `python3 tests/window_controls_smoke.py` additionally creates three disposable GTK processes and verifies real KWin close, application quit, and force-quit behavior. It rejects a stale process identity before force-quitting the selected fixture. Existing applications are not targeted.

## Local todos, Pomodoro, window layouts, and paste queue

| Command | Action |
| --- | --- |
| `todo add buy milk` (or `todo buy milk`) | Append `- [ ] buy milk` to local `todos.md` |
| `todo` / `todo done` | List open/completed tasks; Enter toggles completion |
| `pomodoro` / `pomodoro 25m` | Start a focus timer and keep awake until it ends or is cancelled |
| `layout save work` | Save KWin window positions under `work` |
| `layout work` / `layout restore work` | Restore open windows from the saved layout |
| `layout` / `layout delete work` | List layouts / remove saved positions |
| `clip queue` | Review, select, and reorder clipboard pins for repeated pasting |
| `clip queue stop` | Stop the active queue |

Todos live in `$XDG_DATA_HOME/spotlight/todos.md` (default `~/.local/share/spotlight/todos.md`) and can be edited externally. Updates reject stale selected lines. Layouts and Pomodoro deadlines use Spotlight's existing private store. Window restore uses KWin and never launches missing apps. Disconnected-screen geometry is clamped to a connected screen. Pomodoro uses a separate inhibitor from manual Caffeinate, released at expiry or cancellation; Spotlight must run to ring or inhibit sleep.

The queue requires the optional Qt 6 / KDE GuiAddons helper (`sh native/build-pastequeue.sh`), automatically built by `install.sh` when those development packages are available. KDE Wayland background access uses KSystemClipboard / data-control. The paste queue offers text or PNG images and advances on clipboard content requests. Paste at least 150 ms apart; a clipboard-reading utility other than Klipper can also consume an entry. Copying something else cancels the queue. Queue payloads now use an in-memory pipe, with no plaintext pin or manifest files. Unlock the Clipboard Vault before selecting pins; locking or expiry stops the queue, and stopping clears its current offer. `python3 tests/workflow_smoke.py` uses temporary XDG data, one disposable KWin window, real Caffeinate, and a separate GTK paste destination; it restores the previous text/image clipboard afterward.

## Passwords, network, file vault, and appearance

| Command | Result |
| --- | --- |
| `pass github` | Copy a password on Enter; choose rbw or KeePassXC |
| `rbw github`, `rbw UUID` | Use rbw's existing local Bitwarden cache; its pinentry handles unlock |
| `keepass setup` | Save database and optional key-file paths through a local picker |
| `keepass Group/GitHub` | Ask for the database password, then copy the exact entry's password |
| `ping 8.8.8.8` | Three probes, four-second deadline, including packet-loss statistics |
| `dig github.com` | DNS report with a bounded timeout |
| `my ports`, `my routes` | Local listening TCP/UDP sockets and IPv4 routes |
| `scan wifi` | Scan nearby Wi-Fi networks with nmcli; does not connect to one |
| `encrypt file ~/Documents/report.pdf` | Passphrase-protected AES-256 GPG file beside the original |
| `decrypt file ~/Documents/report.pdf.gpg` | Restore a separate plaintext file; original ciphertext kept |
| `checksum file ~/Downloads/archive.zip` | Preview and copy a SHA-256 checksum |
| `shred file ~/Documents/disposable.txt` | Confirm three overwrite passes, one zero pass, and removal |
| `wallpaper next` | Cycle local images and remember the last successfully applied one |
| `wallpaper ~/Pictures/photo.jpg` | Apply a local image through KDE Plasma |
| `accent blue`, `accent #635BDB` | Change KDE and Spotlight accent while preserving other Spotlight colors |

Password queries prepare actions without reading secrets or opening an unlock prompt while typing. Install and configure [rbw](https://github.com/doy/rbw#configuration) separately and log in before using its cached vault. Spotlight never invokes login or sync; rbw's own background synchronization remains governed by its settings (`sync_interval = 0` disables its periodic sync). Ambiguous names fail rather than choosing a password; use the entry UUID. KeePassXC uses an exact entry path in a password-protected database, with an optional key file. Key-only and hardware-key databases are not supported by this prompt. Database and key-file paths are the only KeePassXC settings Spotlight saves. See the [KeePassXC CLI manual](https://github.com/keepassxreboot/keepassxc/blob/develop/docs/man/keepassxc-cli.1.adoc).

Passwords are copied as text with KDE's `x-kde-passwordManagerHint=secret` metadata. Compatible clipboard managers can exclude them from history; other managers may retain copies. Spotlight clears its clipboard offer after 30 seconds if it still owns that exact offer, preserving anything copied afterward. Keep Spotlight running until expiry. Password results are never previewed, cached, logged, or saved to favorites or usage history. CLI errors are redacted. Master passwords and encryption passphrases go through stdin, never process arguments or saved settings. Cancel and Escape clear the prompt.

Network results load after the normal search debounce. Ping contacts the named host; dig uses your configured DNS resolver; Wi-Fi scanning uses your wireless adapter. These commands intentionally use the requested network and have no cloud fallback. Ports/routes are local snapshots. Enter on the first row opens a full copyable preview; later rows copy individual lines. Results show up to 60 lines inline and retain a bounded full report. Ctrl+R refreshes. Missing tools or unavailable adapters produce an error. Dependencies: iputils `ping`, bind/dnsutils `dig`, iproute2 `ss`/`ip`, and NetworkManager `nmcli`.

File actions also appear under Tab/Ctrl+K in Search File and Recent. Omitting a file path opens a picker. Encryption asks for the passphrase twice, uses GnuPG's symmetric AES-256 mode, and saves `filename.gpg`; decryption removes `.gpg`/`.pgp` or appends `.decrypted`. Existing destinations are refused, including symlinks. Outputs are published only after success with mode 0600. Originals remain unchanged. Back up the passphrase separately; Spotlight does not retain it. [GnuPG documents the symmetric encryption command](https://gnupg.org/documentation/manuals/gnupg/Operational-GPG-Commands.html).

Shredding requires a separate confirmation and rejects directories, symlinks, devices, multiple hard links, and files changed since confirmation. It overwrites an open file descriptor before removing the selected path. Overwriting does **not** guarantee physical erasure on SSDs, copy-on-write filesystems, snapshots, backups, or journalled data; use disk encryption for protection at rest. Interrupted shredding may leave a partially overwritten file. These file operations time out after two minutes.

Wallpaper cycling searches `~/Pictures/Wallpapers`, `~/.local/share/wallpapers`, and `wallpapers` under XDG data directories (default `/usr/share/wallpapers`), up to 500 images and five directory levels. It skips symlinks, sorts paths, wraps at the end, and downloads nothing. KDE may apply the image to multiple desktops/monitors according to its wallpaper tool. Accent names include blue, red, green, purple, orange, pink and teal; six-digit HEX also works. Appearance changes run only on Enter. They require KDE's `plasma-apply-wallpaperimage` / `plasma-apply-colorscheme`. The launcher keeps its current background, text and selection colors.

`python3 tests/systemtools_smoke.py` verifies password CLI argument contracts and redacted failures with fake vaults, bounded network reports, real GPG encryption/decryption and wrong-passphrase handling in a temporary GNUPGHOME, real checksums, and shredding of a disposable fixture. Appearance CLIs are stubbed. With a desktop display it also checks native confirmation cancellation, passphrase mismatch/cancellation, database setup, sensitive MIME formats, privacy, file menus, and saved appearance state. It does not access a personal vault, change your wallpaper/accent, or copy passwords to your desktop clipboard.
