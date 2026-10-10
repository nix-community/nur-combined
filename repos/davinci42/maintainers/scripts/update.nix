{
  package,
  skip-prompt ? true,
}:
let
  pkgs = import <nixpkgs> { };
  info = import ../../tools/update-info.nix {
    inherit pkgs;
    name = package;
  };
  data = pkgs.writeText "nur-update-packages.json" (
    builtins.toJSON [
      {
        name = info.env.UPDATE_NIX_NAME;
        pname = info.env.UPDATE_NIX_PNAME;
        oldVersion = info.env.UPDATE_NIX_OLD_VERSION;
        updateScript = info.command;
        inherit (info) supportedFeatures attrPath;
      }
    ]
  );
in
pkgs.mkShell {
  packages = [
    pkgs.git
    pkgs.nix
    pkgs.cacert
  ];
  shellHook = ''
    unset shellHook
    exec ${pkgs.python3.interpreter} ${pkgs.path}/maintainers/scripts/update.py ${data} ${
      pkgs.lib.optionalString (skip-prompt == true || skip-prompt == "true") "--skip-prompt"
    }
  '';
}
