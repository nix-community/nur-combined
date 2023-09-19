# this file configures preferences per program, without actually enabling any programs.
# the goal is to separate the place where we decide *what* to use (i.e. `sane.programs.firefox.enable = true` -- at the toplevel)
# from where we specific how that thing should behave *if* it's in use.
#
# NixOS backgrounds:
# - <https://github.com/NixOS/nixos-artwork>
#   - <https://github.com/NixOS/nixos-artwork/issues/50>  (colorful; unmerged)
#   - <https://github.com/NixOS/nixos-artwork/pull/60/files>  (desktop-oriented; clean; unmerged)
# - <https://itsfoss.com/content/images/2023/04/nixos-tutorials.png>

{ lib, pkgs, sane-lib, ... }:
{
  sane.programs.firefox.config = {
    # compromise impermanence for the sake of usability
    persistCache = "private";
    persistData = "private";

    # i don't do crypto stuff on moby
    addons.ether-metamask.enable = false;
    # sidebery UX doesn't make sense on small screen
    addons.sidebery.enable = false;
  };
  sane.programs.swaynotificationcenter.config = {
    backlight = "backlight";  # /sys/class/backlight/*backlight*/brightness
  };

  sane.gui.sxmo = {
    nogesture = true;
    settings = {
      ### hardware: touch screen
      SXMO_LISGD_INPUT_DEVICE = "/dev/input/by-path/platform-1c2ac00.i2c-event";
      # vol and power are detected correctly by upstream


      ### preferences
      # notable bemenu options:
      #   - see `bemenu --help` for all
      #   -P, --prefix          text to show before highlighted item.
      #   --scrollbar           display scrollbar. (none (default), always, autohide)
      #   -H, --line-height     defines the height to make each menu line (0 = default height). (wx)
      #   -M, --margin          defines the empty space on either side of the menu. (wx)
      #   -W, --width-factor    defines the relative width factor of the menu (from 0 to 1). (wx)
      #   -B, --border          defines the width of the border in pixels around the menu. (wx)
      #   -R  --border-radius   defines the radius of the border around the menu (0 = no curved borders).
      #   --ch                  defines the height of the cursor (0 = scales with line height). (wx)
      #   --cw                  defines the width of the cursor. (wx)
      #   --hp                  defines the horizontal padding for the entries in single line mode. (wx)
      #   --fn                  defines the font to be used ('name [size]'). (wx)
      #   --tb                  defines the title background color. (wx)
      #   --tf                  defines the title foreground color. (wx)
      #   --fb                  defines the filter background color. (wx)
      #   --ff                  defines the filter foreground color. (wx)
      #   --nb                  defines the normal background color. (wx)
      #   --nf                  defines the normal foreground color. (wx)
      #   --hb                  defines the highlighted background color. (wx)
      #   --hf                  defines the highlighted foreground color. (wx)
      #   --fbb                 defines the feedback background color. (wx)
      #   --fbf                 defines the feedback foreground color. (wx)
      #   --sb                  defines the selected background color. (wx)
      #   --sf                  defines the selected foreground color. (wx)
      #   --ab                  defines the alternating background color. (wx)
      #   --af                  defines the alternating foreground color. (wx)
      #   --scb                 defines the scrollbar background color. (wx)
      #   --scf                 defines the scrollbar foreground color. (wx)
      #   --bdr                 defines the border color. (wx)
      #
      # colors are specified as `#RRGGBB`
      # defaults:
      # --ab "#222222"
      # --af "#bbbbbb"
      # --bdr "#005577"
      # --border 3
      # --cb "#222222"
      # --center
      # --cf "#bbbbbb"
      # --fb "#222222"
      # --fbb "#eeeeee"
      # --fbf "#222222"
      # --ff "#bbbbbb"
      # --fixed-height
      # --fn 'Sxmo 14'
      # --hb "#005577"
      # --hf "#eeeeee"
      # --line-height 20
      # --list 16
      # --margin 40
      # --nb "#222222"
      # --nf "#bbbbbb"
      # --no-overlap
      # --no-spacing
      # --sb "#323232"
      # --scb "#005577"
      # --scf "#eeeeee"
      # --scrollbar autohide
      # --tb "#005577"
      # --tf "#eeeeee"
      # --wrap
      BEMENU_OPTS = let
        bg = "#1d1721";       # slight purple
        fg0 = "#d8d8d8";      # inactive text (light grey)
        fg1 = "#ffffff";      # active text   (white)
        accent0 = "#1f5e54";  # darker but saturated teal
        accent1 = "#418379";  # teal (matches nixos-bg)
        accent2 = "#5b938a";  # brighter but muted teal
      in lib.concatStringsSep " " [
        "--wrap --scrollbar autohide --fixed-height"
        "--center --margin 45"
        "--no-spacing"
        # XXX: font size doesn't seem to take effect (would prefer larger)
        "--fn 'monospace 14' --line-height 22 --border 3"
        "--bdr '${accent0}'"                     # border
        "--scf '${accent2}' --scb '${accent0}'"  # scrollbar
        "--tb '${accent0}' --tf '${fg0}'"        # title
        "--fb '${accent0}' --ff '${fg1}'"        # filter (i.e. text that's been entered)
        "--hb '${accent1}' --hf '${fg1}'"        # selected item
        "--nb '${bg}' --nf '${fg0}'"             # normal lines (even)
        "--ab '${bg}' --af '${fg0}'"             # alternated lines (odd)
        "--cf '${accent0}' --cb '${accent0}'"    # cursor (not very useful)
      ];
      DEFAULT_COUNTRY = "US";

      SXMO_AUTOROTATE = "1";  # enable auto-rotation at launch. has no meaning in stock/upstream sxmo-utils

      # BEMENU lines (wayland DMENU):
      # - camera is 9th entry
      # - flashlight is 10th entry
      # - config is 14th entry. inside that:
      #   - autorotate is 11th entry
      #   - system menu is 19th entry
      #   - close is 20th entry
      # - power is 15th entry
      # - close is 16th entry
      SXMO_BEMENU_LANDSCAPE_LINES = "11";  # default 8
      SXMO_BEMENU_PORTRAIT_LINES = "16";  # default 16
      SXMO_LOCK_IDLE_TIME = "15";  # how long between screenoff -> lock -> back to screenoff (default: 8)
      # gravity: how far to tilt the device before the screen rotates
      # for a given setting, normal <-> invert requires more movement then left <-> right
      # i.e. the settingd doesn't feel completely symmetric
      # SXMO_ROTATION_GRAVITY default is 16374
      # SXMO_ROTATION_GRAVITY = "12800";  # uncomfortably high
      # SXMO_ROTATION_GRAVITY = "12500";    # kinda uncomfortable when walking
      SXMO_ROTATION_GRAVITY = "12000";
      SXMO_SCREENSHOT_DIR = "/home/colin/Pictures";  # default: "$HOME"
      # test new scales by running `swaymsg -- output DSI-1 scale x.y`
      # SXMO_SWAY_SCALE = "1.5";  # hard to press gPodder icons
      SXMO_SWAY_SCALE = "1.8";
      # SXMO_SWAY_SCALE = "2";
      SXMO_WORKSPACE_WRAPPING = "5";  # how many workspaces. default: 4

      # wvkbd layers:
      # - full
      # - landscape
      # - special  (e.g. coding symbols like ~)
      # - emoji
      # - nav
      # - simple  (like landscape, but no parens/tab/etc; even fewer chars)
      # - simplegrid  (simple, but grid layout)
      # - dialer  (digits)
      # - cyrillic
      # - arabic
      # - persian
      # - greek
      # - georgian
      WVKBD_LANDSCAPE_LAYERS = "landscape,special,emoji";
      WVKBD_LAYERS = "full,special,emoji";
    };
  };
}
