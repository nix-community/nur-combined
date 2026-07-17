{
  config,
  lib,
  pkgs,
  self,
}:

let
  inherit (lib)
    attrNames
    filter
    subtractLists
    trivial
    importTOML
    concatStringsSep
    assertMsg
    ;

  upstreamStatus = importTOML "${self}/upstream-status.toml";

  pkgNames = attrNames config.packages;
  tomlNames = attrNames upstreamStatus;

  missingFromToml = subtractLists tomlNames pkgNames;
  staleInToml = subtractLists pkgNames tomlNames;

  mergedWithoutRemoveAfter = filter (
    name:
    let
      us = upstreamStatus.${name};
    in
    us.merged or false && !(us ? removeAfter)
  ) tomlNames;

  INFINITY = 1.0e308 * 2; # TODO move to ./lib
  overdueRemovals = filter (
    name: trivial.oldestSupportedRelease > upstreamStatus.${name}.removeAfter or INFINITY
  ) tomlNames;
in
pkgs.runCommand "health-check" { } (
  assert assertMsg (missingFromToml == [ ]) ''
    Missing `upstream-status.toml` entries for: ${concatStringsSep ", " missingFromToml}
    Add a (possibly empty) `[name]` section for each directory under `./packages`.
  '';
  assert assertMsg (staleInToml == [ ]) ''
    `upstream-status.toml` has entries with no corresponding `./packages` directory: ${concatStringsSep ", " staleInToml}
    Remove these sections, or restore the package if this was accidental.
  '';
  assert assertMsg (mergedWithoutRemoveAfter == [ ]) ''
    These packages are `merged` but have no `removeAfter` set: ${concatStringsSep ", " mergedWithoutRemoveAfter}
    Add a `removeAfter` release to schedule removal.
  '';
  assert assertMsg (overdueRemovals == [ ]) ''
    These packages are past their `removeAfter` release EOL: ${concatStringsSep ", " overdueRemovals}
    Delete the `./packages/<name>` directory and its `upstream-status.toml` entry.
  '';
  ''
    touch $out
  ''
)
