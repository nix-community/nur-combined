# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  pyPackageOverrides = pySelf: pySuper: {
    authcaptureproxy = pySelf.callPackage ./pkgs/authcaptureproxy { };
    fiblary3 = pySelf.callPackage ./pkgs/fiblary3 { };
    garminconnect = pySelf.callPackage ./pkgs/garminconnect { };
    ha-dyson = pySelf.callPackage ./pkgs/ha-dyson { };
    ha-dyson-cloud = pySelf.callPackage ./pkgs/ha-dyson-cloud { };
    haManifestRequirementsCheckHook = pySelf.callPackage pkgs/build-support/ha-custom-components/ha-manifest-requirements-check-hook.nix {};
    homeassistant = (pySelf.toPythonModule pkgs.home-assistant).overrideAttrs (o: {
      # tests take a really long time
      doInstallCheck = false;
    });
    homeassistant-stubs = pySelf.callPackage ./pkgs/homeassistant-stubs { };
    libdyson = pySelf.callPackage ./pkgs/libdyson { };
    libpurecool = pySelf.callPackage ./pkgs/libpurecool { };
    monkeytype = pySelf.callPackage ./pkgs/monkeytype { };
    pynut2 = pySelf.callPackage ./pkgs/pynut2 { };
    ring_doorbell = pySelf.callPackage ./pkgs/ring_doorbell { };
    tesla-custom-component = pySelf.callPackage ./pkgs/tesla-custom-component { };
    teslajsonpy = pySelf.callPackage ./pkgs/teslajsonpy { };
  } // pkgs.lib.optionalAttrs (pkgs.lib.hasPrefix "21.05" pkgs.lib.version) {
    smartbox = pySelf.callPackage ./pkgs/smartbox { };
    hass-smartbox = pySelf.callPackage ./pkgs/hass-smartbox { };
    pytest-homeassistant-custom-component = pySelf.callPackage ./pkgs/pytest-homeassistant-custom-component { };
  };
in rec {
  inherit pkgs; # for debugging

  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # TODO: fix
  #enroot = pkgs.callPackage ./pkgs/enroot { };

  python37 = pkgs.python37.override {
    packageOverrides = pyPackageOverrides;
  };
  python37Packages = python37.pkgs;

  python38 = pkgs.python38.override {
    packageOverrides = pyPackageOverrides;
  };
  python38Packages = python38.pkgs;

  python39 = pkgs.python39.override {
    packageOverrides = pyPackageOverrides;
  };
  python39Packages = python39.pkgs;

  python3 = python38;
  python3Packages = python38Packages;
}
