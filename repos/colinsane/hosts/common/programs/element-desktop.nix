# debugging tips:
# - if element opens but does not render:
#   - `element-desktop --disable-gpu --in-process-gpu`
#     - <https://github.com/vector-im/element-desktop/issues/1029#issuecomment-1632688224>
#   - `rm -rf ~/.config/Element/GPUCache`
#     - <https://github.com/NixOS/nixpkgs/issues/244486>
{ lib, pkgs, ... }:
{
  sane.programs.element-desktop = {
    # packageUnwrapped = (pkgs.element-desktop.override {
    #   # use pre-built electron because otherwise it takes 4 hrs to build from source.
    #   electron = pkgs.electron-bin;
    # }).overrideAttrs (upstream: {
    packageUnwrapped = pkgs.element-desktop.overrideAttrs (upstream: {
      # fix to use wayland instead of Xwayland:
      # - replace `NIXOS_OZONE_WL` non-empty check with `WAYLAND_DISPLAY`
      # - use `wayland` instead of `auto` because --ozone-platform-hint=auto still prefers X over wayland when both are available
      # alternatively, set env var: `ELECTRON_OZONE_PLATFORM_HINT=wayland` and ignore all of this
      installPhase = lib.replaceStrings
        [ "NIXOS_OZONE_WL" "--ozone-platform-hint=auto" ]
        [ "WAYLAND_DISPLAY" "--ozone-platform-hint=wayland" ]
        upstream.installPhase
      ;
    });
    suggestedPrograms = [
      "gnome-keyring"
    ];

    buildCost = 1;

    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  # notifications
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Music"
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];
    sandbox.extraPaths = [
      "/dev/snd"  #< needed only when playing embedded audio (not embedded video!)
    ];

    # creds/session keys, etc
    persist.byStore.private = [ ".config/Element" ];
  };
}
