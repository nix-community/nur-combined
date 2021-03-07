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
    hass-smartbox = pySelf.callPackage ./pkgs/hass-smartbox { };
    homeassistant = let
      tmpPython = pySelf.python.override {
        packageOverrides = pySelf': pySuper': {
          buildPythonApplication = pySelf'.buildPythonPackage;
        };
      };
    in
      tmpPython.pkgs.callPackage "${pkgs.path}/pkgs/servers/home-assistant" {};
    libpurecool = pySelf.callPackage ./pkgs/libpurecool { };
    pynut2 = pySelf.callPackage ./pkgs/pynut2 { };
    python-engineio_3 = pySelf.callPackage ./pkgs/python-engineio/3.nix { };
    python-socketio_4 = pySelf.callPackage ./pkgs/python-socketio/4.nix { };
    ring_doorbell = pySelf.callPackage ./pkgs/ring_doorbell { };
    smartbox = pySelf.callPackage ./pkgs/smartbox { };
    teslajsonpy = pySelf.callPackage ./pkgs/teslajsonpy { };
  } // pkgs.lib.optionalAttrs (pkgs.lib.hasPrefix "21.05" pkgs.lib.version) {
    pytest-homeassistant-custom-component = pySelf.callPackage ./pkgs/pytest-homeassistant-custom-component { };
  };
in rec {
  inherit pkgs; # for debugging

  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  enroot = pkgs.callPackage ./pkgs/enroot { };

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
