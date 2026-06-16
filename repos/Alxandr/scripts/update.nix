{
  package ? null,
  list ? false,
  allow-dirty ? false,
  pkgs ? import <nixpkgs> {
    config.allowUnfree = true;
  },
}:

let
  inherit (pkgs) lib;

  nurAttrs = import ../default.nix { inherit pkgs; };

  reservedAttrs = [
    "lib"
    "overlays"
    "nixosModules"
    "homeModules"
    "darwinModules"
    "flakeModules"
  ];

  packageAttrs = lib.filterAttrs (
    name: value: !(builtins.elem name reservedAttrs) && lib.isDerivation value
  ) nurAttrs;

  packagesWithUpdateScript = lib.filterAttrs (
    _: value: (value.updateScript or null) != null
  ) packageAttrs;

  selectedPackages =
    if package == null then
      packagesWithUpdateScript
    else if builtins.hasAttr package packagesWithUpdateScript then
      { ${package} = packagesWithUpdateScript.${package}; }
    else if builtins.hasAttr package packageAttrs then
      throw "Package '${package}' does not have a passthru.updateScript attribute defined."
    else
      throw "Package '${package}' does not exist.";

  packageData = lib.mapAttrsToList (
    attrPath: package:
    let
      updateScript = package.updateScript;
    in
    {
      attrPath = updateScript.attrPath or attrPath;
      name = package.name;
      pname = lib.getName package;
      oldVersion = lib.getVersion package;
      updateScript = map toString (lib.toList (updateScript.command or updateScript));
    }
  ) selectedPackages;

  printPackage = package: ''
    printf '%s\n' ${lib.escapeShellArg package.attrPath}
  '';

  updatePackage = package: ''
    echo "Updating ${package.attrPath}..." >&2
    export UPDATE_NIX_NAME=${lib.escapeShellArg package.name}
    export UPDATE_NIX_PNAME=${lib.escapeShellArg package.pname}
    export UPDATE_NIX_OLD_VERSION=${lib.escapeShellArg package.oldVersion}
    export UPDATE_NIX_ATTR_PATH=${lib.escapeShellArg package.attrPath}
    ${lib.escapeShellArgs package.updateScript}
  '';

  runScript =
    if list then
      lib.concatMapStringsSep "\n" printPackage packageData
    else
      ''
        if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
          echo "The updater must be run from inside a git worktree." >&2
          exit 1
        fi

        if [ "$(git rev-parse --show-toplevel)" != "$PWD" ]; then
          echo "The updater must be run from the repository root." >&2
          exit 1
        fi

        ${lib.optionalString (!allow-dirty) ''
          if [ -n "$(git status --porcelain)" ]; then
            echo "Refusing to run updaters with a dirty git worktree." >&2
            exit 1
          fi
        ''}

        ${lib.concatMapStringsSep "\n" updatePackage packageData}
      '';
in
pkgs.stdenv.mkDerivation {
  name = "nur-update-script";

  buildCommand = ''
    echo "Run this updater with nix-shell scripts/update.nix." >&2
    exit 1
  '';

  nativeBuildInputs = [
    pkgs.git
    pkgs.nix
    pkgs.cacert
  ];

  shellHook = ''
    unset shellHook
    set -euo pipefail
    ${runScript}
    exit 0
  '';
}
