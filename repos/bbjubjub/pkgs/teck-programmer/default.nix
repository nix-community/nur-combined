{ pkgs, lib, nodejs, stdenv }:

let
  nodePackages = import ./composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };
in
  nodePackages.teck-programmer.override ({meta, ...}: {
    nativeBuildInputs = [ nodePackages.node-gyp-build ];
    buildInputs = [ pkgs.libusb1 ];
    meta = meta // {
      license = lib.licenses.gpl3Plus;
      mainProgram = "teck-firmware-upgrade";
    };
  })
