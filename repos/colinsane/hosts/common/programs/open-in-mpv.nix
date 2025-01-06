# test: `open-in-mpv 'mpv:///open?url=https://www.youtube.com/watch?v=dQw4w9WgXcQ'`
{ pkgs, ... }:
{
  sane.programs.open-in-mpv = {
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  # for xdg-open/portals

    # taken from <https://github.com/Baldomo/open-in-mpv>
    fs.".config/open-in-mpv/config.yml".symlink.text = ''
      players:
        mpv:
          name: mpv
          executable: xdg-open
          supported_protocols:
            - http
            - https
          fullscreen: ""
          pip: ""
          enqueue: ""
          new_window: ""
          needs_ipc: false
          flag_overrides: {}
    '';

    mime.associations = {
      "x-scheme-handler/mpv" = "open-in-mpv.desktop";
    };
  };
}
