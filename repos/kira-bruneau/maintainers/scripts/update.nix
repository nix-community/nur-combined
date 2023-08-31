{ lib
, writeText
, writeShellScript
, python3
, nixpkgs
, packages
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
  echo "" | ${python3.interpreter} ${nixpkgs + "/maintainers/scripts/update.py"} ${packagesJson} --keep-going --commit "$@"
''
