# ChatGPT

This package uses the upstream Linux Debian archive. The main app retains the
upstream layout under `lib/chatgpt`.

## Contents

Paths below are relative to `lib/chatgpt`.

| Path | Role | Packaging |
| --- | --- | --- |
| `ChatGPT` and adjacent runtime files | Custom Owl/Electron runtime, libraries, snapshots and locales | Main app |
| `resources/app.asar` | Application code and web assets | Main app |
| `resources/app.asar.unpacked` | Files shipped outside the ASAR, including native modules | Main app |
| `resources/codex`, `resources/codex-code-mode-host` | Bundled executables | Main app |
| `resources/rg` | ripgrep | Link to the Nixpkgs package |
| `resources/plugins`, `resources/skills` | Bundled plugins and skills | Main app |
| `resources/cua_node` | Node runtime and its bundled modules | Link to an independent output |
| `resources/tectonic` | Static TeX engine | Link to an independent output |

Tools downloaded at runtime to `~/.cache/codex-runtimes` are handled by `nix-ld`.
They are separate from the bundled components in the Nix closure.

The app uses Nixpkgs' glibc build of ripgrep through its original `resources/rg`
path, sharing the package with other Nix consumers. In local tests on a large
directory tree, this build was faster than the bundled musl build.

## Component reuse

`cua_node` and Tectonic each have a fixed output name and an independent content
hash for their extracted source. An app release can change the Debian archive
without changing either component's store path. The updater verifies the archive
and computes both component hashes before updating `source.nix`.

`cua_node` is patched in its own derivation so its library paths do not depend on
the main app's store path. Reuse requires unchanged component content, patching
rules and build dependencies. Tectonic is statically linked and uses the extracted
output directly.

The main app links to these outputs instead of keeping additional copies. The
Debian archive and unpatched `cua_node` source are build inputs only. The runtime
closure still contains all bundled tools; the benefit is reusing unchanged
components across updates.

Splitting follows standalone files or directories in the upstream layout. ASAR
contents stay together, without unpacking and regrouping internal assets. Further
splits need evidence of content stability. Owl is a custom runtime, so its
Electron version alone does not establish that its contents are unchanged.
