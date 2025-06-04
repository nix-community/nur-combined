{ pkgs, ... }:
{
  sane.programs.zoom-us = {
    packageUnwrapped = pkgs.zoom-us.override {
      xdgDesktopPortalSupport = true;  #< what does this do? who knows!
    };
    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistAvDev = true;  #< XXX(2025-05-29): it doesn't use pipewire for mic/video
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.whitelistX = true;  # XXX(2025-05-29): required; TODO: try setting QP_... env vars to get native wayland?
    sandbox.tmpDir = ".zoom";  #< tmpdir needs to be shared between instances, for the singleton socket to work (also, it needs to exist)
    mime.associations."x-scheme-handler/zoommtg" = "Zoom.desktop";  #< for when you click on a meeting link
    # TODO: .config/{zoom,zoomus}.conf
    # TODO: .config/Unknown Organization/zoom.conf
    persist.byStore.ephemeral = [
      ".cache/zoom"  # 8MB qmlcache
    ];
    persist.byStore.private = [
      ".zoom"  # 400MB of app-data (i.e. Zoom downloads its assets instead of shipping them in the package)
    ];
  };
}
