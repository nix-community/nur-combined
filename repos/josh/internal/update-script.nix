# FLAKE_URI="$PWD" UPDATE_NIX_ATTR_PATH=foo nix run --file ./internal/update-script.nix
let
  system = builtins.currentSystem;
  flake = builtins.getFlake (builtins.getEnv "FLAKE_URI");
  attr = builtins.getEnv "UPDATE_NIX_ATTR_PATH";

  inherit (flake.inputs.nixpkgs) lib;
  pkgs = import flake.inputs.nixpkgs {
    inherit system;
  };

  pkg = flake.packages.${system}.${attr};

  inherit (pkg) name;
  pname = lib.strings.getName pkg;
  version = lib.strings.getVersion pkg;

  updateScriptArgs = builtins.map builtins.toString (
    lib.lists.toList (pkg.updateScript.command or pkg.updateScript)
  );
  updateCommand = lib.strings.escapeShellArgs (updateScriptArgs ++ [ "--commit" ]);
in
pkgs.writeShellScriptBin "update-${attr}" ''
  set -o xtrace
  UPDATE_NIX_NAME=${name} UPDATE_NIX_PNAME=${pname} UPDATE_NIX_OLD_VERSION=${version} UPDATE_NIX_ATTR_PATH=${attr} ${updateCommand}
''
