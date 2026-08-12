# `bin/prelude`

Only `00-core-sd.sh` lives here. `bin/shim/sd` execs it for non-interactive `sd` / `sdw`.

Interactive shell snippets are **not** loaded from this directory. They come from workspaced home apply:

- `config/.bashrc.d.tmpl/` — main dotfiles root snippets
- `modules/*/home/.bashrc.d.tmpl/` — module chunks (concat into `~/.bashrc`)

Nix code that needs a snippet should read those paths (see `sshfs.nix`, `bootstrap/default.nix`), not add copies here.

The `script-directory` module embeds the same `00-core-sd.sh` into `~/.bashrc` for the `sd` shell function. Keep that file in sync with this one when changing sd behavior.
