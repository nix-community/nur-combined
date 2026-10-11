# Generate the update-unit list for `_scripts/run-update-scripts.sh`.
#
# An unit is either:
#   - a package with a non-null `passthru.updateScript` (`update` = the update.py record), or
#   - an nvfetcher source not consumed by any updateScript unit (`update` = null).
#
# `update` records follow the `packageData` contract of nixpkgs'
# `maintainers/scripts/update.nix`: `command or self` → `lib.toList` → `toString`,
# with `attrPath`/`supportedFeatures` passed through. Evaluation goes through
# `import ../pkgs { }` (the repo's evaluation root is `pkgs/`), so path literals stay
# real working-tree paths and update scripts can write sidecar files next to themselves.
#
# `sources` lists the nvfetcher sources an unit refreshes first; by convention an unit
# owns the source named after its canonical `attrPath`.
{
  pkgs ? import <nixpkgs> { },
  # Restrict to these unit names; empty list means all.
  select ? [ ],
}:
let
  inherit (pkgs) lib;
  scope = import ../pkgs { inherit pkgs; };
  nvfetcherSources = builtins.attrNames (lib.importTOML ../nvfetcher.toml);

  # tryEval guards packages that fail to evaluate; optional drops non-derivations and
  # packages without an update script.
  recordOf =
    name: value:
    let
      evaluated = builtins.tryEval value;
      us =
        if evaluated.success && lib.isDerivation evaluated.value then
          evaluated.value.updateScript or null
        else
          null;
    in
    lib.optional (us != null) {
      inherit name;
      pname = lib.getName evaluated.value;
      oldVersion = lib.getVersion evaluated.value;
      updateScript = map toString (lib.toList (us.command or us));
      supportedFeatures = us.supportedFeatures or [ ];
      attrPath = us.attrPath or name;
    };

  # Run a script shared by multiple attributes only once. The key includes attrPath
  # because bare `nix-update` commands are textually identical across packages and are
  # told apart by UPDATE_NIX_ATTR_PATH; a genuinely shared script opts in by pinning the
  # same `attrPath` on each declaration. Attribute names may not carry string context,
  # so the grouping key discards it — the kept records retain theirs (they reference the
  # store paths to realize).
  dedup =
    entries:
    map lib.head (
      builtins.attrValues (
        lib.groupBy (
          e:
          builtins.unsafeDiscardStringContext (
            builtins.toJSON [
              e.updateScript
              e.attrPath
            ]
          )
        ) entries
      )
    );

  updateUnits = map (e: {
    inherit (e) name;
    sources = lib.optional (lib.elem e.attrPath nvfetcherSources) e.attrPath;
    update = e;
  }) (dedup (lib.concatLists (lib.mapAttrsToList recordOf scope)));

  covered = lib.concatMap (u: u.sources) updateUnits;
  sourceUnits = map (s: {
    name = s;
    sources = [ s ];
    update = null;
  }) (lib.subtractLists covered nvfetcherSources);

  units = lib.sortOn (u: u.name) (updateUnits ++ sourceUnits);
in
lib.filter (u: select == [ ] || lib.elem u.name select) units
