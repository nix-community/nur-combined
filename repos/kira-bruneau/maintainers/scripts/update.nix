{
  lib,
  substitute,
  writeText,
  writeShellApplication,
  packages,
  coreutils,
  git,
  nix,
  nixpkgs,
  python3,
}:

let
  updateScript = substitute {
    src = "${nixpkgs}/maintainers/scripts/update.py";
    substitutions = [
      "--replace"
      ''nixpkgs_root + "/shell.nix"''
      ''"${nixpkgs}/shell.nix"''
    ];
  };

  dedupe =
    packages:
    builtins.attrValues (
      builtins.listToAttrs (
        builtins.map (data: {
          name = data.package.meta.position;
          value = data;
        }) packages
      )
    );

  packageData =
    { package, attrPath }:
    {
      name = package.name;
      pname = lib.getName package;
      oldVersion = lib.getVersion package;
      updateScript = map builtins.toString (
        lib.toList (package.updateScript.command or package.updateScript)
      );
      supportedFeatures = package.updateScript.supportedFeatures or [ ];
      attrPath = package.updateScript.attrPath or attrPath;
    };

  packagesJson = writeText "packages.json" (builtins.toJSON (map packageData (dedupe packages)));
in
writeShellApplication {
  name = "update";
  runtimeInputs = [ coreutils ];
  text = ''
    temp_home="$(mktemp -d)"
    env -i \
      HOME="$temp_home" \
      GIT_CONFIG_GLOBAL="$HOME/.config/git/config" \
      PATH=${
        lib.makeBinPath [
          coreutils
          git
          nix
        ]
      } \
      NIX_PATH=nixpkgs=${nixpkgs} \
      ${python3.interpreter} ${updateScript} ${packagesJson} \
        --keep-going \
        --commit \
        --skip-prompt \
        "$@"
    rm -rf "$temp_home"
  '';
}
