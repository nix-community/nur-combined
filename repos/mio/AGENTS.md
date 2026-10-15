# Agent notes

- In this flake repo, run `git add` for newly created files before `nix build .#...`, because untracked files are not included in flake evaluation.
- Use the modern SRI format for hashes (e.g. `hash = "sha256-..."`) instead of the legacy `sha256 = "..."` attribute. You can convert old hashes using `nix hash convert <hash>` or `nix hash to-sri --type sha256 <hash>`. Note that `builtins.fetchTarball` does NOT support the `hash` attribute (only the deprecated `sha256=` is supported); use `pkgs.fetchzip` instead when you need to fetch tarballs and use the modern `hash=` attribute.
- NEVER FORCE PUSH! Just commit and `git push` normally. UNLESS YOU ACCIDENTLY PUSHED binary or other unneeded big files to git history ONLY IN THIS CASE push --force acceptable
- ALWAYS confirm that `nix build` passes successfully and the built app functions correctly before committing and pushing any changes.
- CRITICAL: Make absolutely sure `nix build` passes before ANY push!
- When developing Hanga specifically, the development gate is `nix build .#hanga-dev` (runs host, mod, and xvfb agent tests). Do not wait on `nix build .#hanga` for day-to-day Hanga work; that wrap skips the long cargo checkPhase.
- Omnimux vendors `gpui-terminal`: see `by-name/om/omnimux/VENDOR.md` for upstream baselines (gpui-terminal, alacritty_terminal and the patched gpui-pre platform crates) and our local patches. App-level notes (appearance/OSC, sessions, packaging): `by-name/om/omnimux/README.md`.
- Always check `git status` to clean up any temporary files or scratch scripts created during problem solving.
- "check updates" or similar requests mean you should run `./check_updates.py`.
- Standard Nixpkgs versioning rule: NEVER use a commit hash directly as `version`! For unreleased packages or builds tracking git commits/branches, follow the standard Nixpkgs convention:
  - If there is a prior release/tag or known base version: `version = "<base-version>-unstable-<YYYY-MM-DD>";` (e.g. `"5.0-unstable-2026-04-21"` or `"6.0.0-unstable-2026-10-03"`).
  - If there are no prior releases: `version = "0-unstable-<YYYY-MM-DD>";`.
  - Put the git commit hash in a separate attribute or local binding (`rev = "...";` or `commit = "...";`) rather than in `version`.

