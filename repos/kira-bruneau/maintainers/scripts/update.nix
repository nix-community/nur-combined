{
  lib,
  writeText,
  writeShellApplication,
  packages,
  coreutils,
  bash,
  git,
  nix,
  nixpkgs,
  python3,
}:

let
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

  packagesJson = writeText "packages.json" (builtins.toJSON (map packageData packages));
in
writeShellApplication {
  name = "update";
  text = ''
    echo "" | ${coreutils}/bin/env -i \
      HOME="$HOME" \
      PATH=${
        lib.makeBinPath [
          bash
          coreutils
          git
          nix
        ]
      } \
      NIX_PATH=nixpkgs=${nixpkgs} \
      ${python3.interpreter} ${
        nixpkgs + "/maintainers/scripts/update.py"
      } ${packagesJson} --keep-going --commit "$@"
  '';
}
