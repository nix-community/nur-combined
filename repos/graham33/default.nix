# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  myPackages = pkgs.lib.makeScope pkgs.newScope (self: with self; {

    ha-dyson = callPackage ./pkgs/ha-dyson { };
    ha-dyson-cloud = callPackage ./pkgs/ha-dyson-cloud { };

    hass-smartbox = callPackage ./pkgs/hass-smartbox {};

    home-assistant = (pkgs.home-assistant.override {
      # TODO: fix upstream
      extraPackages = ps: [ps.ifaddr];
      packageOverrides = homeAssistantPackageOverrides;
    }).overrideAttrs (o: {
      # tests take a really long time
      doInstallCheck = false;
    });

    homeAssistantPackageOverrides = pySelf: pySuper: rec {
      buildHomeAssistantCustomComponent = callPackage pkgs/build-support/build-home-assistant-custom-component {};

      # authcaptureproxy = pySelf.callPackage ./pkgs/authcaptureproxy { };
      # fiblary3 = pySelf.callPackage ./pkgs/fiblary3 { };
      garminconnect = pySelf.callPackage ./pkgs/garminconnect { };
      homeassistant = (pySelf.toPythonModule home-assistant);
      homeassistant-stubs = pySelf.callPackage ./pkgs/homeassistant-stubs { };
      libdyson = pySelf.callPackage ./pkgs/libdyson { };
      monkeytype = pySelf.callPackage ./pkgs/monkeytype { };
      pynut2 = pySelf.callPackage ./pkgs/pynut2 { };
      pytest-homeassistant-custom-component = pySelf.callPackage ./pkgs/pytest-homeassistant-custom-component { };
      python-engineio_3 = pySelf.callPackage ./pkgs/python-engineio/3.nix { };
      python-socketio_4 = pySelf.callPackage ./pkgs/python-socketio/4.nix { };
      ring_doorbell = pySelf.callPackage ./pkgs/ring_doorbell { };
      smartbox = pySelf.callPackage ./pkgs/smartbox { };
      # typer = pySelf.callPackage ./pkgs/typer { };

      # These use a conflicting version of python-socketio
      aioambient = null;
      simplisafe-python = null;
    };

    python3 = let
      packageOverrides = pySelf: pySuper: rec {
        json_exporter = pySelf.callPackage ./pkgs/json_exporter { };
      };
    in
      pkgs.python3.override { inherit packageOverrides; self = python3; };
    python3Packages = python3.pkgs;

    tesla-custom-component = callPackage ./pkgs/tesla-custom-component { };
  });

  # pkg_21-11 = pkg: if (builtins.match "^21\.11.*" pkgs.lib.version != null) then pkg else null;
in rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # for CI
  inherit (pkgs) nix-build-uncached;

  inherit (myPackages)
    ha-dyson
    ha-dyson-cloud
    hass-smartbox
    home-assistant
    homeAssistantPackageOverrides
    tesla-custom-component
  ;

  python3Packages = {
    inherit (myPackages.python3Packages) json_exporter;
  };

  inherit (home-assistant.python.pkgs)
    homeassistant
    homeassistant-stubs
    pytest-homeassistant-custom-component
    smartbox
  ;
}
