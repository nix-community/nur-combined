{
  pkgs ? import <nixpkgs> { },
}:
let
  pico-sdk = pkgs.callPackage ./pkgs/pico-sdk.nix { };
  picotool = pkgs.callPackage ./pkgs/picotool.nix { inherit pico-sdk; };
  pico-keys-sdk = pkgs.callPackage ./pkgs/pico-keys-sdk/default.nix { };
  callPkgWithSdk = pkgs.lib.callPackageWith (
    pkgs
    // {
      inherit picotool;
      inherit pico-keys-sdk;
      pico-sdk-full = pico-sdk.override {
        withSubmodules = true;
      };
    }
  );
  pico-hsm-packages = callPkgWithSdk ./pkgs/pico-hsm-packages.nix { };
  pico-fido-packages = callPkgWithSdk ./pkgs/pico-fido-packages.nix { };
in
rec {
  inherit picotool;

  overlays = import ./overlays;

  pycvc = pkgs.callPackage ./pkgs/pycvc.nix { };
  pypicohsm = pkgs.callPackage ./pkgs/pypicohsm.nix { inherit pycvc; };

  pico-openpgp = callPkgWithSdk ./pkgs/pico-openpgp.nix { };

  pico-hsm = pkgs.callPackage pico-hsm-packages.pico-hsm { };
  pico-hsm-tool = pkgs.callPackage (pico-hsm-packages.pico-hsm-tool) {
    inherit pycvc pypicohsm;
  };

  pico-fido = pkgs.callPackage pico-fido-packages.pico-fido { };
  pico-fido-tool = pico-fido-packages.pico-fido-tool;

  pico-nuke = callPkgWithSdk ./pkgs/pico-nuke.nix { };
}
