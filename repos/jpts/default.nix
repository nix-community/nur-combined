# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{ pkgs ? import <nixpkgs> { } }:
let
  nurPkgs = rec {
    # The `lib`, `modules`, and `overlay` names are special
    lib = import ./lib { inherit pkgs; }; # functions
    #modules = import ./modules; # NixOS modules
    #overlays = import ./overlays; # nixpkgs overlays

    rbac-police = pkgs.callPackage ./pkgs/rbac-police { };
    coredns-enum = pkgs.callPackage ./pkgs/coredns-enum { };
    penelope = pkgs.python3Packages.callPackage ./pkgs/penelope { };
    kubectl-execws = pkgs.callPackage ./pkgs/kubectl-execws { };
    stats = pkgs.callPackage ./pkgs/stats { };
    blueutil = pkgs.callPackage ./pkgs/blueutil {
      inherit (pkgs.darwin.apple_sdk_11_0.frameworks) Foundation IOBluetooth;
    };
    sleepwatcher = pkgs.callPackage ./pkgs/sleepwatcher {
      inherit (pkgs.darwin.apple_sdk_11_0.frameworks) Foundation IOKit;
    };
    patator = pkgs.python3Packages.callPackage ./pkgs/patator { };
    cherrypy-cors = pkgs.python3Packages.callPackage ./pkgs/cherrypy-cors { };
    httplib2shim = pkgs.python3Packages.callPackage ./pkgs/httplib2shim { };
    insomnium = pkgs.callPackage ./pkgs/insomnium { };
    inso = pkgs.callPackage ./pkgs/inso { };
    scoutsuite = pkgs.python3Packages.callPackage ./pkgs/scoutsuite {
      cherrypy-cors = nurPkgs.cherrypy-cors;
      httplib2shim = nurPkgs.httplib2shim;
    };
    granted = pkgs.callPackage ./pkgs/granted { };
    curl = pkgs.callPackage ./pkgs/curl {
      idnSupport = true;
      zstdSupport = true;
      c-aresSupport = true;
      ipv6Support = true;
    };
  };
in
nurPkgs
