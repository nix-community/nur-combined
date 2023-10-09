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
