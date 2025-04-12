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
  pico-hsm-eddsa-packages = pkgs.callPackage ./pkgs/pico-hsm-packages.nix {
    rev = "v5.4-eddsa1";
    hash = "sha256-38rg5NhQnJSVrHFywQxKTK3kxy6EktPNxJAZNIWe5Mw=";
  };
  pico-fido-packages = pkgs.callPackage ./pkgs/pico-fido-packages.nix { };
  pico-fido-eddsa-packages = pkgs.callPackage ./pkgs/pico-fido-packages.nix {
    rev = "v6.4-eddsa1";
    hash = "sha256-Fqbn5349IzpKYIRzsYAJhmqDQCCd9ERcjlBXQeemt9c=";
  };
in
rec {
  inherit picotool;

  overlays = import ./overlays;

  pycvc = pkgs.callPackage ./pkgs/pycvc.nix { };
  pypicohsm = pkgs.callPackage ./pkgs/pypicohsm.nix { inherit pycvc; };

  pico-openpgp = callPkgWithSdk ./pkgs/pico-openpgp.nix { };

  pico-openpgp-eddsa = pico-openpgp.override {
    rev = "v3.4-eddsa1";
    hash = "sha256-6ObCH1EFRyGzCmemO+J8mMr637RNyxCwEArWS//IECc=";
  };

  pico-hsm = callPkgWithSdk (pico-hsm-packages.pico-hsm) { };
  pico-hsm-tool = pkgs.callPackage (pico-hsm-packages.pico-hsm-tool) {
    inherit pycvc pypicohsm;
  };

  pico-hsm-eddsa = callPkgWithSdk (pico-hsm-eddsa-packages.pico-hsm) { };

  pico-nuke = callPkgWithSdk ./pkgs/pico-nuke.nix { };

  pico-fido = callPkgWithSdk (pico-fido-packages.pico-fido) { };
  pico-fido-tool = pico-fido-packages.pico-fido-tool;

  pico-fido-eddsa = callPkgWithSdk (pico-fido-eddsa-packages.pico-fido) { };
}
