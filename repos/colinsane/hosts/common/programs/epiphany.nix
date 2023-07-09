# epiphany web browser
# - GTK4/webkitgtk
#
# usability notes:
# - touch-based scroll works well (for moby)
# - URL bar constantly resets cursor to the start of the line as i type
#   - maybe due to the URLbar suggestions getting in the way
{ pkgs, ... }:
{
  sane.programs.epiphany = {
    # XXX(2023/07/08): running on moby without this hack fails, with:
    # - `bwrap: Can't make symlink at /var/run: File exists`
    # this could be due to:
    # - epiphany is somewhere following a symlink into /var/run instead of /run
    #   - (nothing in `env` or in this repo touches /var/run)
    # - no xdg-desktop-portal is installed  (unlikely)
    #
    # a few other users have hit this, in different contexts:
    # - <https://gitlab.gnome.org/GNOME/gnome-builder/-/issues/1164>
    # - <https://github.com/flatpak/flatpak/issues/3477>
    package = pkgs.writeShellScriptBin "epiphany" ''
      WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS=1 ${pkgs.epiphany}/bin/epiphany
    '';
    persist.private = [
      ".cache/epiphany"
      ".local/share/epiphany"
      # also .config/epiphany, but appears empty
    ];
  };
}
