# FLAKE_URI="$PWD" nix eval --raw --file ./internal/update-script-attrs.nix
let
  system = builtins.currentSystem;
  flake = builtins.getFlake (builtins.getEnv "FLAKE_URI");
  pkgs = import flake.inputs.nixpkgs { inherit system; };
  packages = import "${flake}/default.nix" { inherit pkgs; };

  preferredSystem =
    name:
    let
      pkg = packages.${name};
      platforms = pkg.meta.platforms or [ ];
    in
    if builtins.elem "x86_64-linux" platforms then
      "x86_64-linux"
    else if builtins.elem "aarch64-darwin" platforms then
      "aarch64-darwin"
    else
      throw "Unsupported platform: ${system}";

  shouldUpdatePackage =
    name: (builtins.hasAttr "updateScript" packages.${name}) && ((preferredSystem name) == system);

  attrs = builtins.filter shouldUpdatePackage (builtins.attrNames packages);
in
"attrs=${builtins.toJSON attrs}"
