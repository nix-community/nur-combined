# Agent notes

- In this flake repo, run `git add` for newly created files before `nix build .#...`, because untracked files are not included in flake evaluation.
- Use the modern SRI format for hashes (e.g. `hash = "sha256-..."`) instead of the legacy `sha256 = "..."` attribute. You can convert old hashes using `nix hash convert <hash>` or `nix hash to-sri --type sha256 <hash>`. Note that `builtins.fetchTarball` does NOT support the `hash` attribute (only the deprecated `sha256=` is supported); use `pkgs.fetchzip` instead when you need to fetch tarballs and use the modern `hash=` attribute.
- NEVER FORCE PUSH! Just commit and `git push` normally.
- ALWAYS confirm that `nix build` passes successfully and the built app functions correctly before committing and pushing any changes.
- CRITICAL: Make absolutely sure `nix build` passes before ANY push!
- Omnimux vendors `gpui-terminal`: see `by-name/om/omnimux/src/vendor/gpui-terminal/VENDOR.md` for upstream baseline commit and our local patches. App-level notes (appearance/OSC, sessions, packaging): `by-name/om/omnimux/README.md`.
