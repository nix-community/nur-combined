{
  pkgs ? import <nixpkgs> { },
}:
let
  pico-sdk = pkgs.callPackage ./pkgs/pico-sdk.nix { };
  picotool = pkgs.callPackage ./pkgs/picotool.nix { inherit pico-sdk; };
  callPkgWithSdk = pkgs.lib.callPackageWith (
    pkgs
    // {
      inherit picotool;
      pico-sdk-full = pico-sdk.override {
        withSubmodules = true;
      };
    }
  );
  pico-hsm-packages = pkgs.callPackage ./pkgs/pico-hsm-packages.nix { };
  pico-fido-packages = pkgs.callPackage ./pkgs/pico-fido-packages.nix { };
in
rec {
  overlays = import ./overlays;

  pycvc = pkgs.callPackage ./pkgs/pycvc.nix { };
  pypicohsm = pkgs.callPackage ./pkgs/pypicohsm.nix { inherit pycvc; };

  pico-openpgp = callPkgWithSdk ./pkgs/pico-openpgp.nix { };

  pico-openpgp-eddsa = pico-openpgp.override {
    version = "3.2";
    rev = "7050e6b19f03d5956fd14930dcefab97dc213834";
    hash = "sha256-Bja4cyRreQr5siTJcUMPgsqT4uNgvdzWeCEST5xQuFs=";
  };

  pico-hsm = callPkgWithSdk (pico-hsm-packages.pico-hsm) { };
  pico-hsm-tool = pkgs.callPackage (pico-hsm-packages.pico-hsm-tool) {
    inherit pycvc pypicohsm;
  };

  pico-nuke = callPkgWithSdk ./pkgs/pico-nuke.nix { };

  pico-fido = callPkgWithSdk (pico-fido-packages.pico-fido) { };
  pico-fido-tool = pico-fido-packages.pico-fido-tool;
}
