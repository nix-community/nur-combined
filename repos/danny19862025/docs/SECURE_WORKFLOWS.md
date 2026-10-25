# Secure pins, visual workflows, and contextual local AI

## Secure Clipboard Vault

Search **Secure Clipboard Vault**, `vault`, or `clip vault`. The first use asks you to choose and repeat a master password. Later unlocks ask for that password. While unlocked, Clipboard History → select text/image → Ctrl+K → Pin entry saves an encrypted pin. `clip pinned` lists unlocked pins. Enter copies; Ctrl+K → Unpin entry removes one. Open the vault control again to lock it.

Every pin expires one hour after pinning. Re-pinning the same content refreshes its one-hour lifetime. The unlock session also lasts at most one hour. Expired pins are unavailable immediately and their ciphertext records are removed while Spotlight is running or on its next startup. Locking hides previews, clears the in-memory key, closes secure queue controls, stops active paste queues, and clears any vault clipboard offer it still owns. A copied pin uses sensitive clipboard metadata and a 30-second clipboard timeout; a later unrelated copy is preserved. Other clipboard applications can retain copies they have already received.

On the first successful unlock, Spotlight encrypts existing text and image pins before clearing their plaintext records from `data.json` and removing its old `clipboard-pins` images. If encryption or cleanup fails, the error is shown and the original data is retained for retry. Migration starts the one-hour lifetime. Filesystem snapshots, external backups, and Klipper's separate history are outside this migration; encryption cannot retroactively erase those copies. Clearing Klipper history is a separate confirmed action.

The vault is `$XDG_DATA_HOME/spotlight/clipboard-vault.json` (normally `~/.local/share/spotlight/clipboard-vault.json`), written atomically with mode 0600. It uses [Argon2id](https://docs.rs/argon2/0.5.3/argon2/) with a random 16-byte salt, 64 MiB memory, three iterations, one lane, and a 256-bit key, followed by [XChaCha20-Poly1305 authenticated encryption](https://docs.rs/chacha20poly1305/0.10.1/chacha20poly1305/) with fresh random 24-byte nonces. Pin identifiers and expiry timestamps are authenticated as associated data; payloads and image bytes are encrypted. The key is held in zeroizing memory and is never written to settings, process arguments, or an external password service. Identifiers and expiry times remain visible in the envelope. Pins accept up to 64 KiB of text or an 8 MiB PNG, with at most 50 pins and a 48 MiB encrypted store.

Keep the master password separately. There is no password recovery or cloud synchronization. Losing the password loses access to unexpired pins. The vault protects saved pin contents; applications that receive a paste and screenshots of an unlocked launcher can still contain that content.

The paste queue reads unlocked secure pins and transmits them to the updated KDE helper over a pipe. It creates no plaintext pin or manifest files. Its in-memory offers retain sensitive metadata; expiry or locking stops the queue. Start order and per-entry selection still work. Stopping a secure queue now clears its current offer. Rebuild/install the helper with `sh native/build-pastequeue.sh` if upgrading manually.

## Workflow Builder

Search **Workflow Builder**, `workflow`, or `workflow new`. Choose an example or use **Add action**, select each action, and use ↑/↓ or Remove to arrange the vertical chain. Translate has a target-language field. Save WASM stores the definition; Save & Run opens the runner. Review the chain and choose Run chain. Input actions use the runner's input field; intermediate values are passed to the next action.

Available actions:

| Action | Input and result |
| --- | --- |
| Input text | Use text entered in the runner |
| Clipboard text | Read current clipboard text, up to 64 KiB |
| Screenshot | Ask the desktop Screenshot portal for a capture |
| OCR image | Convert the preceding screenshot into text using Tesseract |
| Translate locally | Translate text into the configured language with local Ollama |
| Summarize locally | Summarize text with local Ollama |
| Save note | Save current text through Spotlight's existing quick-note destination |
| Copy text | Copy current text to the clipboard |

For `screenshot → OCR → translate → note`, choose the first example, enter a target language, and save. Screenshot selection/cancellation uses your desktop portal. OCR requires Tesseract; translation/summarization require a configured local Ollama model and the same verified local-only server as other AI commands. There are no model downloads or cloud fallbacks. A failed action stops the chain; completed notes or copies remain. Cancel discards unfinished work and cancels local AI generation. OCR is bounded to 30 seconds, screenshot requests to 45 seconds, and AI requests to 95 seconds.

Use `workflow run name`, `workflow edit name`, and `workflow delete name` to find saved chains. Deletion asks for confirmation and removes only the workflow module. Notes it already created remain. A workflow has 1–12 typed actions; image/text mismatches are rejected when saving. Runtime text is limited to 64 KiB and captures to 16 MiB. Screenshots and intermediate text stay in memory; only explicit Save Note or Copy actions publish their output.

Workflows are genuine binary WASM modules in `$XDG_DATA_HOME/spotlight/workflows/<id>.wasm`, with mode 0600. A versioned custom section stores editable action metadata, and an exported `workflow_step(index) -> i32` function executes the action schedule in Wasmi with a 10,000-fuel budget. Loading validates both the WASM and its canonical correspondence to the metadata. Guest modules have no imports, memory, filesystem, shell, or network capabilities. The reviewed GTK host performs only the listed actions. This is a separate workflow ABI from the existing extension SDK; third-party WASM plugins retain their existing sandbox. Saved modules include workflow names, action choices and language options, not captured text, questions, passphrases or model output.

## Context-aware local AI

Set project context with `project ~/Projects/foo`. Type `ai`, `ai context`, or `ai ask what should I work on next?`, then press Enter. The dialog gathers selected sources and shows the exact snapshot before **Send locally**. Toggle sources or use Refresh context to rebuild it. Opening or refreshing context does not send a model request.

- **Selected project:** the selected directory, up to 100 visible file names three levels deep, and up to four root README/manifest files at 4 KiB each. Hidden, ignored, generated and symlinked paths are omitted.
- **Open window titles:** up to 30 KDE KWin application/title pairs, with the active window marked. If KWin is unavailable, that is shown in the context.
- **todos.md:** Spotlight's local todos and a `todos.md` in the selected project, up to 8 KiB each.

The total snapshot is capped at 48,000 bytes, and question plus encoded context at 64 KiB. Repository file contents beyond the listed README/manifests are not automatically read. Review the snapshot when discussing confidential work. The model receives project/window/todo content as untrusted data and has no tools that can execute instructions in it.

The client uses only a literal loopback Ollama endpoint, bypasses proxies, refuses redirects, verifies cloud-disabled status and local model weights before sending a prompt, and has no cloud fallback. Start Ollama with `OLLAMA_NO_CLOUD=1` and install/configure a local text model separately. Settings → General selects a model; `ai models` lists local models. `ai summarize clipboard` remains available.

Questions, snapshots and answers stay in memory and are excluded from saved usage/favorites. Copy answer and Save answer as note are explicit actions; the latter creates a normal local/Obsidian note. Closing cancels an in-flight request. Ollama's own logging/storage policy is independent of Spotlight.

## Verification

`cargo test --offline --locked --all-targets` covers authenticated encryption, wrong-password and tampering rejection, expiry while locked, typed-chain validation, truncated/modified WASM rejection, real Wasmi scheduling, and bounded context/ignored-file handling.

`python3 tests/deep_features_smoke.py` adds isolated vault migration, native visual editing, screenshot-portal/OCR/local-model fixtures, screenshot → OCR → translation → note execution, cancellation, context preview/source selection, persistence privacy, and cloud/remote/redirect refusal before generation. Screenshots use fixture images. It does not read a personal vault or send prompts to a real model. With no display it runs the backend fixtures only.

`python3 tests/workflow_smoke.py` checks real KDE paste-queue behavior, including reordered text and image pastes using the new pipe transport and clearing on stop, and restores the previous clipboard. Existing personal windows are not moved; it creates a disposable fixture window for its layout checks.
