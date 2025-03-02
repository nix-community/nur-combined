# FLAKE_URI="$PWD" nix eval --raw --file ./internal/update-script-matrix.nix
let
  system = builtins.currentSystem;
  flake = builtins.getFlake (builtins.getEnv "FLAKE_URI");
  pkgs = flake.packages.${system};

  commands = builtins.filter (x: x != null) (
    builtins.map (
      name:
      let
        pkg = pkgs.${name};
      in
      if !(builtins.hasAttr "updateScript" pkg) then
        null
      else if !pkg.meta.available then
        null
      else
        { "attr" = name; }
    ) (builtins.attrNames pkgs)
  );

  matrix = {
    include = commands;
  };
in
"matrix=${builtins.toJSON matrix}"
