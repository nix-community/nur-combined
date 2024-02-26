# rofi: app-launcher/file-browser/omni-menu
#
# select options:
# - `rofi -show`
#   - use as a launcher/file browser
# - `rofi -sidebar-mode`
#   - separate tabs for filebrowser, drun, etc.
# - `rofi -pid /run/user/$UID/rofi.pid -replace`
#   - single-instance mode
#   - pid is probably optional, just need `-replace`.
#
# ROFI POWERSCRIPTS/EXTENSIONS/PLUGINS:
# collections:
# - <https://github.com/adi1090x/rofi>
# - <https://github.com/giomatfois62/rofi-desktop>
#   - turns rofi into a hierarchical menu, like sxmo
#
# - <https://github.com/adi1090x/rofi>
# - <https://github.com/marvinkreis/rofi-file-browser-extended>
# - <https://github.com/Mange/rofi-emoji>
# - <https://github.com/fdw/rofimoji>
# - <https://github.com/jluttine/rofi-power-menu>
# - <https://github.com/ceuk/rofi-screenshot>
# - <https://gitlab.com/DamienCassou/rofi-pulse-select>
{ pkgs, ... }:
{
  sane.programs.rofi = {
    # 2024/02/26: wayland is only supported by the fork: <https://github.com/lbonn/rofi>.
    # it's actively maintained though, and more of an overlay than a true fork.
    packageUnwrapped = pkgs.rofi-wayland;

    fs.".config/rofi/config.rasi".symlink.target = ./config.rasi;
    # redirect its default drun cache location
    fs.".cache/rofi-drun-desktop.cache".symlink.target = "rofi/rofi-drun-desktop.cache";
    persist.byStore.cryptClearOnBoot = [
      # optional, for caching .desktop files rofi finds on disk (perf)
      ".cache/rofi"
    ];
  };
}
