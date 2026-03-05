{
  pkgs ? import <nixpkgs> { },
}:

let
  # Optionally override versions here, if you want to easily bump them
  hash = "sha256-IOFtMAYSdpXhWKMQdlGtF6rOGrMT5X4u5TOME8x5kA8=";
in

pkgs.callPackage ./package.nix {
  inherit hash;
}
