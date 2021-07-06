{ pkgs ? import <nixpkgs> { } }: with pkgs.lib; let
  pkgs' = pkgs;
  arc = import ../. { pkgs = pkgs.extend pythonTestOverlay; };
  overlays = import ../overlays;
  pythonTestOverlay = self: super: {
    pythonOverrides = super.pythonOverrides or { } // {
      arc'test = { python }: python.version;
    };
  };
  pkgsOverlayFetchurl = pkgs.extend overlays.fetchurl;
  pkgsOverlayPackages = pkgs.extend overlays.packages;
  pkgsOverlayArc = pkgs.extend overlays.arc;
  pkgsOverlayOverrides = pkgs.extend overlays.overrides;
  pkgsOverlayPython = (pkgs.extend overlays.python).extend pythonTestOverlay;
  pkgsOverlayShells = pkgs.extend overlays.shells;
  pkgsManualOverlay = pkgs.extend (self: super: {
    arc = import ../. { pkgs = self; };
  });
  pkgsOverlay = (overlays.wrap pkgs).extend pythonTestOverlay;
  compare = a: b:
    if isFunction a then functionArgs a == functionArgs b
    else a == b;
  testAll = tests: all id tests;
  tests = {
    individualOverlayFetchurl = { pkgs ? pkgsOverlayFetchurl }: testAll (
    optionals (overlays.hasOverlay "fetchurl" pkgs) [
      (!(compare pkgs.fetchurl pkgs'.fetchurl))
      (compare pkgs.nixpkgsFetchurl pkgs'.fetchurl)
    ]);
    overlayPackages = { pkgs ? pkgsOverlayPackages }: testAll [
      (pkgs ? screenstub)
      (pkgs.pass-arc.outPath != "")
      (arc.packages.pass-arc.outPath != "")
    ];
    overlayArc = { pkgs ? pkgsOverlayArc }: testAll [
      (pkgs ? arc.packages)
    ];
    overlayPython = { pkgs ? pkgsOverlayPython }: testAll [
      (pkgs.python3Packages.arc'test != pkgs.python2.pkgs.arc'test)
    ];
    overlayOverrides = { pkgs ? pkgsOverlayOverrides }: testAll (
    optionals (overlays.hasOverlay "overrides" pkgs) [
      (pkgs.notmuch.pname != "notmuch")
      (pkgs.nixpkgsNotmuch.pname == "notmuch")
      (pkgs.notmuch.super.pname == "notmuch")
    ]);
    overlayShells = { pkgs ? pkgsOverlayShells }: testAll (
    optionals (overlays.hasOverlay "shells" pkgs) [
      ((pkgs.mkShell { }) ? shellEnv)
    ]);
    manualOverlay = { pkgs ? pkgsManualOverlay }: testAll [
      (pkgs ? arc.packages.screenstub)
    ];
  };
in mapAttrs (_: v: v { }) tests //
  mapAttrs' (k: v: nameValuePair "${k}'wrapped" (v { pkgs = pkgsOverlay; })) tests //
  mapAttrs' (k: v: nameValuePair "${k}'channel" (v { pkgs = arc.pkgs; })) tests
