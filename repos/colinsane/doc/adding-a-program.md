to ship `pkgs.foo` on some host, either:
- add it as an entry in `suggestedPrograms` to the appropriate category in `hosts/common/programs/assorted.nix`, or
- `sane.programs.foo.enableFor.user.colin = true` in `hosts/by-name/myhost/default.nix`

if the program needs customization (persistence, configs, secrets):
- add a file for it at `hosts/common/programs/<foo>.nix`
- set the options, `sane.programs.foo.{fs,persist}`

if it's unclear what fs paths a program uses:
- run one of these commands, launch the program, run it again, and `diff`:
  - `du -x --apparent-size ~`
  - `find ~ -xdev`
- or, inspect the whole tmpfs root with `ncdu -x /`
