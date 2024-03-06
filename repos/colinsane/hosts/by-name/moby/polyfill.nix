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

  sane.programs.alacritty.config.fontSize = 9;

  sane.programs.sway.config = {
    font = "pango:monospace 10";
    mod = "Mod1";  # prefer Alt
    workspace_layout = "tabbed";
  };

  sane.programs.waybar.config = {
    fontSize = 14;
    height = 26;
    persistWorkspaces = [ "1" "2" "3" "4" "5" ];
    modules.media = false;
    modules.network = false;
    modules.perf = false;
    modules.windowTitle = false;
    # TODO: show modem state
  };
}
