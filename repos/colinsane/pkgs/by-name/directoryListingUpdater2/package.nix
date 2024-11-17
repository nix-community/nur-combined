# heavily based on <repo:nixos/nixpkgs:pkgs/common-updater/scripts.nix>
# and <repo:nixos/nixpkgs:pkgs/common-updater/scripts/list-directory-versions>.
# main difference is that it does fuzzier matching.
#
# remove this package once this PR lands:
# - <https://github.com/NixOS/nixpkgs/pull/347619>
{
  lib,
  genericUpdater,
  static-nix-shell,
}:

{
  pname ? null,
  version ? null,
  attrPath ? null,
  allowedVersions ? "",
  ignoredVersions ? "",
  rev-prefix ? "",
  odd-unstable ? false,
  patchlevel-unstable ? false,
  url ? null,
  extraRegex ? null,
}:
let
  list-directory-versions = static-nix-shell.mkPython3 {
    pname = "list-directory-versions";
    srcRoot = ./.;
    pkgs = [
      "python3.pkgs.beautifulsoup4"
      "python3.pkgs.requests"
    ];
  };
in
genericUpdater {
  inherit
    pname
    version
    attrPath
    allowedVersions
    ignoredVersions
    rev-prefix
    odd-unstable
    patchlevel-unstable
    ;
  versionLister = "${lib.getExe list-directory-versions} ${
    lib.optionalString (url != null) "--url=${lib.escapeShellArg url}"
  } ${lib.optionalString (extraRegex != null) "--extra-regex=${lib.escapeShellArg extraRegex}"}";
}
