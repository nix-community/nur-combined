
{ pkgs ? import <nixpkgs> {} }:

let
  inherit (pkgs) lib stdenv;

  # Shared arguments to inject into every package
  sharedOverrides = {
    versionCheckHook = pkgs.versionCheckHook;
    writeShellScript = pkgs.writeShellScriptBin or pkgs.writeShellScript;
    xcbuild = pkgs.xcbuild;
  };

  maybeEnable = drv:
    if lib.elem stdenv.hostPlatform.system (drv.meta.platforms or []) then drv else null;

  # Now call every package with the shared overrides
  openaudible   = maybeEnable (pkgs.callPackage ./pkgs/media/openaudible sharedOverrides);
  chatterino    = maybeEnable (pkgs.callPackage ./pkgs/chat/chatterino sharedOverrides);
  kobo-desktop  = maybeEnable (pkgs.callPackage ./pkgs/media/kobo-desktop sharedOverrides);

in {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;
} // lib.filterAttrs (_: v: v != null) {
  inherit openaudible chatterino kobo-desktop;
}

