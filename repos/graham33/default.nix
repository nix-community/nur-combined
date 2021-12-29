# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  pyPackageOverrides = pySelf: pySuper: rec {
    authcaptureproxy = pySelf.callPackage ./pkgs/authcaptureproxy { };
    fiblary3 = pySelf.callPackage ./pkgs/fiblary3 { };
    garminconnect = pySelf.callPackage ./pkgs/garminconnect { };
    ha-dyson = pySelf.callPackage ./pkgs/ha-dyson { };
    ha-dyson-cloud = pySelf.callPackage ./pkgs/ha-dyson-cloud { };
    haManifestRequirementsCheckHook = pySelf.callPackage pkgs/build-support/ha-custom-components/ha-manifest-requirements-check-hook.nix {};
    hass-smartbox = pySelf.callPackage ./pkgs/hass-smartbox { };
    homeassistant = (pySelf.toPythonModule home-assistant);
    homeassistant-stubs = pySelf.callPackage ./pkgs/homeassistant-stubs { };
    libdyson = pySelf.callPackage ./pkgs/libdyson { };
    # libpurecool = pySelf.callPackage ./pkgs/libpurecool { };
    monkeytype = pySelf.callPackage ./pkgs/monkeytype { };
    pynut2 = pySelf.callPackage ./pkgs/pynut2 { };
    pytest-homeassistant-custom-component = pySelf.callPackage ./pkgs/pytest-homeassistant-custom-component { };
    python-engineio_3 = pySelf.callPackage ./pkgs/python-engineio/3.nix { };
    python-socketio_4 = pySelf.callPackage ./pkgs/python-socketio/4.nix { };
    ring_doorbell = pySelf.callPackage ./pkgs/ring_doorbell { };
    smartbox = pySelf.callPackage ./pkgs/smartbox { };
    tesla-custom-component = pySelf.callPackage ./pkgs/tesla-custom-component { };
    #teslajsonpy = pySelf.callPackage ./pkgs/teslajsonpy { };
    typer = pySelf.callPackage ./pkgs/typer { };

    # These use a conflicting version of python-socketio
    aioambient = null;
    simplisafe-python = null;
  };

  home-assistant = (pkgs.home-assistant.override {
    # TODO: fix upstream
    extraPackages = ps: [ps.ifaddr];
    packageOverrides = pyPackageOverrides;
  }).overrideAttrs (o: {
    # tests take a really long time
    doInstallCheck = false;
  });

  # pkg_21-11 = pkg: if (builtins.match "^21\.11.*" pkgs.lib.version != null) then pkg else null;

in rec {
  inherit pkgs; # for debugging

  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  inherit home-assistant;

  # packages to cache (all versions)
  inherit (home-assistant.python.pkgs)
    hass-smartbox
    homeassistant
    homeassistant-stubs
    pytest-homeassistant-custom-component
    smartbox
  ;
}
