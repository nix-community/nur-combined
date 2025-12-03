# FIRST TIME SETUP:
# - [x] in ~/.config/zoom/zoomus.conf: toggle `xwayland=true` -> `xwayland=false` (by now screen sharing works)
# - [ ] TODO: in ~/.config/zoom/zoomus.conf: toggle `enableMiniWindow=true` -> `enableMiniWindow=false` (hopefully provides a way to exit from screenshare?)
#
# tips for configuring zoom:
# - <https://wiki.archlinux.org/title/Zoom_Meetings>
# - <https://www.reddit.com/r/archlinux/comments/19ecsv5/comment/ktot9hf/>
# webrtc screen sharing:
# - <https://github.com/emersion/xdg-desktop-portal-wlr/wiki/Screencast-Compatibility>
# - <https://wiki.archlinux.org/title/PipeWire#WebRTC_screen_sharing>
# - <https://mozilla.github.io/webrtc-landing/gum_test.html>
{ pkgs, ... }:
{
  sane.programs.zoom-us = {
    packageUnwrapped = (pkgs.zoom-us.override {
      xdgDesktopPortalSupport = true;  #< what does this do? who knows!
      # gnomeXdgDesktopPortalSupport = true;
      # wlrXdgDesktopPortalSupport = true;
    });
    # .overrideAttrs (upstream: {
    #   # force wayland. even w/ x11 removed from the sandbox, it still manages to connect! probably it does it via the network.
    #   # so explicitly set QT_QPA_PLATFORM=wayland, and as a precaution, unset `DISPLAY`
    #   # XXX(2025-07-31): QT_QPA_PLATFORM=wayland is NOT needed if XDG_SESSION_TYPE=wayland is set instead.
    #   #   XDG_SESSION_TYPE=wayland is *also* required for pipewire screen sharing to work.
    #   #   setting anything here is no longer required, as i set XDG_SESSION_TYPE at the sway layer.
    #   nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
    #     pkgs.makeShellWrapper
    #   ];
    #   buildCommand = upstream.buildCommand + ''
    #     wrapProgram $out/bin/zoom \
    #       --run 'if [[ -n "''${WAYLAND_DISPLAY:-}" ]]; then export QT_QPA_PLATFORM=wayland; unset DISPLAY; fi'
    #   '';
    # });
    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistAvDev = true;  #< XXX(2025-05-29): it doesn't use pipewire for mic/video
    sandbox.whitelistDri = true;
    sandbox.whitelistPortal = [
      "Camera"  # not sure if used
      "OpenURI"
      "ScreenCast"  # not sure if used
    ];
    sandbox.whitelistWayland = true;
    # sandbox.whitelistX = true;  # XXX(2025-05-29): required; TODO: try setting QP_... env vars to get native wayland?
    sandbox.tmpDir = ".cache/.zoom";  #< tmpdir needs to be shared between instances, for the singleton socket to work (also, it needs to exist)
    mime.associations."x-scheme-handler/zoommtg" = "Zoom.desktop";  #< for when you click on a meeting link
    # TODO: .config/Unknown Organization/zoom.conf
    persist.byStore.private = [
      ".cache/zoom"  # 8MB qmlcache + 400MB app data (assets Zoom downloads at runtime instead of shipping the package) via the ~/.zoom -> .cache/zoom
      ".config/zoom"
    ];

    # coerce Zoom into using XDG dirs:
    fs.".zoom".symlink.target = ".cache/zoom";
    fs.".config/zoom.conf".symlink.target = "zoom/zoom.conf";
    fs.".config/zoomus.conf".symlink.target = "zoom/zoomus.conf";
  };
}
