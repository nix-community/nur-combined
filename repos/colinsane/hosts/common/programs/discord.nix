{ lib, pkgs, ... }: {
  sane.programs.discord = {
    # nixpkgs' discord defaults to X11 backend isntead of wayland, UNLESS NIXOS_OZONE_WL is specified.
    # better to enable wayland support via package override instead of polluting the global env.
    packageUnwrapped = pkgs.discord.overrideAttrs (base: {
      installPhase = lib.replaceStrings [ "NIXOS_OZONE_WL" ] [ "WAYLAND_DISPLAY" ] base.installPhase;
    });

    sandbox.mesaCacheDir = ".cache/discord/mesa";
    # creds, but also 200 MB of node modules, etc
    persist.byStore.private = [ ".config/discord" ];
    sandbox.wrapperType = "inplace";  #< package contains broken symlinks that my wrapper can't handle
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  # needed for xdg-open
    sandbox.whitelistDri = true;  #< required for even basic graphics (e.g. rendering a window)
    sandbox.whitelistWayland = true;
    sandbox.net = "clearnet";
    sandbox.extraHomePaths = [
      # still needs these paths despite it using the portal's file-chooser :?
      "Pictures/cat"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];
  };
}
