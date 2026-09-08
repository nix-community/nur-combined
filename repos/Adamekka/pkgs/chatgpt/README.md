# ChatGPT for Linux

Packages OpenAI's official Linux desktop preview, including Codex, for
`aarch64-linux` and `x86_64-linux`. This is not a web wrapper or the separate
Codex CLI package. OpenAI does not officially support NixOS.

From the repository root:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix run --impure .#chatgpt
```

For a NixOS or Home Manager installation, allow the unfree `chatgpt` package
and add this repository's `chatgpt` output to your package list. Installing
the package provides the `chatgpt` command, desktop entry, icon, and upstream
file and `codex://` URL associations.

The app uses XWayland by default. Native Wayland is experimental upstream;
launch with `chatgpt --ozone-platform=wayland` to opt in. Linux computer use
is not yet supported by OpenAI. The package does not disable Chromium's sandbox.

## Runtime and cache

The launcher uses an app-scoped FHS environment to provide conventional Linux
library and executable paths, including for tools downloaded after installation.
It does not require host-wide `nix-ld` configuration or modify the vendor archive.
This environment is for compatibility, not a security boundary: ChatGPT retains
access to your files and network. The host must permit unprivileged user namespaces.
On Ubuntu, AppArmor may require a local policy allowing the Nix-store launcher;
do not work around this by passing `--no-sandbox` to ChatGPT.

The launcher copies approximately 45 MiB of bundled plugins into
`${XDG_CACHE_HOME:-$HOME/.cache}/chatgpt-nix/`, keyed by the immutable package path.
It makes this copy writable because ChatGPT edits plugin manifests after copying
them. Large unchanged resources remain symlinks to the Nix store. A lock and an
atomic rename protect initialization when multiple launches happen together.
Old package copies are retained for rollbacks; after closing ChatGPT, you can
remove unused copies or the entire `chatgpt-nix` cache. The launcher recreates it.
This cache is separate from your projects, chats, and installed plugin state.

OpenAI separately downloads and updates its workspace tools under
`$HOME/.cache/codex-runtimes`. These downloads are upstream application behavior
and are not pinned by this Nix package. They run inside the same FHS environment.
Python uses Nix's CA certificate bundle unless you supply `SSL_CERT_FILE`.

## Updates

`source.json` pins versioned official Debian downloads and their SHA-256 hashes.
Run `python3 pkgs/chatgpt/update.py` from the repository root with Python 3 and
curl available, or use the package's `passthru.updateScript`. The updater reads
OpenAI's HTTPS package indexes, verifies changed downloads, and refuses mismatched
architecture versions, downgrades, and unexpected package metadata.

The daily `Update ChatGPT` workflow commits tested updates directly to `main`,
without opening PRs. It captures the current `main` commit and prepares one
candidate, then calls `Test ChatGPT` with that base and the exact candidate file
bytes. Both native architecture checks must pass before a separate job with
write permission commits only `source.json` and pushes it using `GITHUB_TOKEN`.
If there is no update, validation and publishing are skipped.

`Test ChatGPT` builds natively on amd64 and ARM64 using `flake.lock`, validates
the desktop entry, and runs the updater tests. Outside the Nix build sandbox,
it checks concurrent launches, cache permissions and reuse, and GUI startup with
the bundled Codex process under Xvfb. Chromium's sandbox remains enabled; the
disposable Ubuntu CI VM allows user namespaces for the test. It also runs on
regular PRs and pushes to `main`. It does not upload the proprietary application
to the public binary cache. Login and account-dependent features need manual testing.

Before pushing, the publishing job fetches `main` and aborts if it no longer
matches the tested base. The ordinary non-force push also rejects a concurrent
advance after that check. Start a new manual `Update ChatGPT` run on `main`, or
wait for the next scheduled run, to prepare and validate against the new base.
GitHub's **Re-run jobs** keeps the original triggering commit and cannot refresh
the base. The updater never rebases a tested update onto untested changes.

Both workflow files must be on `main` for scheduled updates. The repository must
allow the workflow's token to push to `main`; these workflows do not change
branch protection. Token-authored pushes do not trigger another push workflow,
so the required ChatGPT build and smoke tests run before publishing rather than
relying on post-push CI.
