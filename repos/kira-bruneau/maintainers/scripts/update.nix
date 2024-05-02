{ lib
, stdenv
, writeText
, writeShellScript
, packages
, coreutils
, bash
, git
, nix
, nixpkgs
, python3
}:

let
  packageData = { package, attrPath }: {
    name = package.name;
    pname = lib.getName package;
    oldVersion = lib.getVersion package;
    updateScript = map builtins.toString (lib.toList (package.updateScript.command or package.updateScript));
    supportedFeatures = package.updateScript.supportedFeatures or [ ];
    attrPath = package.updateScript.attrPath or attrPath;
  };

  packagesJson = writeText "packages.json" (builtins.toJSON (map packageData packages));
in
writeShellScript "update" ''
  echo "" | ${coreutils}/bin/env -i \
    HOME="$HOME" \
    PATH=${bash}/bin:${coreutils}/bin:${git}/bin:${nix}/bin \
    NIX_PATH=nixpkgs=${nixpkgs} \
    ${python3.interpreter} ${nixpkgs + "/maintainers/scripts/update.py"} ${packagesJson} --keep-going --commit "$@"
''
