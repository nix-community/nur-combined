{
  pkgs ? import <nixpkgs> { },
}:

let
  # Optionally override versions here, if you want to easily bump them
  hash = "sha256-vBKLq5WFE3QSN9BgV2N7wmKF+K6G42ylQWu790mWnak=";
in

pkgs.callPackage ./package.nix {
  inherit hash;
}
