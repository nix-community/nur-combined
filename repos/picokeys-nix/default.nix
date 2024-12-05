{
  pkgs ? import <nixpkgs> { },
}:
let
  callPkgWithSdk = pkgs.lib.callPackageWith (
    pkgs
    // {
      pico-sdk-full = pkgs.pico-sdk.override {
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
    version = "3.0";
    rev = "7f24b9f6b8e98caf91315f1a92867e0b99f02139";
    hash = "sha256-s072dyzMoNUEQxYXRGC5l9qCShdL0LvZGqpTBjyACRo=";
  };

  pico-hsm = callPkgWithSdk (pico-hsm-packages.pico-hsm) { };
  pico-hsm-tool = pkgs.callPackage (pico-hsm-packages.pico-hsm-tool) {
    inherit pycvc pypicohsm;
  };

  pico-nuke = callPkgWithSdk ./pkgs/pico-nuke.nix { };

  pico-fido = callPkgWithSdk (pico-fido-packages.pico-fido) { };
  pico-fido-tool = pico-fido-packages.pico-fido-tool;
}
