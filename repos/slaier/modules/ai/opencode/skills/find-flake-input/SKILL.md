---
name: find-flake-input
description: Find the local source path (store path) of a Nix flake input, e.g. where nixpkgs actually comes from on this machine. Use whenever the user asks where a flake input lives, its source path, its store path, which checkout it points to, or wants to browse/edit an input's source code, or wants to look up options/modules of an input (home-manager, nixpkgs, sops-nix...).
---

# find-flake-input

Flake inputs are flakes themselves, so each one's `outPath` is its local store path. Resolve it with `builtins.getFlake`:

```bash
nix eval --raw --impure --expr '(builtins.getFlake (toString ./.)).inputs.<name>.outPath'
```

Run from the flake root (or pass the flake dir instead of `./.`).

Useful extras:
- List all inputs: `nix eval --impure --expr 'builtins.attrNames (builtins.getFlake (toString ./.)).inputs' --json`
- `<name>` may be nested, e.g. `inputs.home-manager.inputs.nixpkgs.outPath` — walk the attrpath.

If the user then wants to inspect that source, `cd` into the returned store path (read-only) or copy it out for editing.

Do NOT guess alternative attrs (`.#inputs...`, `nixosConfigurations.<host>.pkgs.<input>`, channels) — they fail or point at the wrong thing. Always use the `builtins.getFlake` command above.

Options/modules live under: home-manager/sops-nix style flakes -> `modules/`; nixpkgs -> `nixos/modules/` (packages in `pkgs/`); nix-darwin -> `nix-darwin/`.

Module file layout (home-manager style):
- Most modules are flat files, NOT directories: `programs.git` -> `modules/programs/git.nix`.
- Find the right file with: `find <outPath>/modules -iname '*<name>*'` or grep for the option namespace: `grep -rl 'programs.git =' <outPath>/modules`. `programs.git` lives at `modules/programs/git.nix` or `modules/programs/git/default.nix` — check with find.
- The module is the file under `modules/` defining `options.<namespace>`; option-looking helpers under `<outPath>/lib/` (e.g. `lib/git.nix`) are not the module.
- Home-manager module options are usually declared with `mkOption` / `mkEnableOption` / `mkPackageOption`; list them via `grep -n 'mkOption\|mkEnableOption' <file>`. Watch for renames: grep for `mkRenamedOptionModule` for the old->new mapping when an option "doesn't exist".

