# test: `open-in-mpv 'mpv:///open?url=https://www.youtube.com/watch?v=dQw4w9WgXcQ'`
{ pkgs, ... }:
{
  sane.programs.open-in-mpv = {
    packageUnwrapped = pkgs.open-in-mpv.overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        (pkgs.fetchpatch {
          # if i want `open-in-mpv 'mpv:///open?...'` to use a different executable than `mpv` (e.g. `xdg-open`),
          # this patch is required.
          # PR against upstream (merged 2024/02/15): <https://github.com/Baldomo/open-in-mpv/pull/26>
          url = "https://git.uninsane.org/colin/open-in-mpv/commit/4d93d5fbdd3baebb6284c517cfe9fec9970c3002.patch";
          name = "open-in-mpv: respect the player's `executable` config";
          hash = "sha256-UkjR58mo4ifqGU2F1YhcJU14gX41XMaXwImbV+v7Tr8=";
        })
      ];
    });

    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.whitelistDbus = [ "user" ];  # for xdg-open/portals

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
