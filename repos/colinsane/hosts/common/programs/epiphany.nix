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
    sandbox.wrapperType = "inplace";  # /share/epiphany/default-bookmarks.rdf refers back to /share; dbus files to /libexec
    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user.own = [ "org.gnome.Epiphany" ];
    sandbox.whitelistPortal = [
      # these are all speculative
      "Camera"
      "FileChooser"
      "Location"
      "OpenURI"
      "Print"
      "ProxyResolver"  #< required else it doesn't load websites
      "ScreenCast"
    ];
    # default sandboxing breaks rendering in weird ways. sites are super zoomed in / not scaled.
    # enabling DRI/DRM (as below) seems to fix that.
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      ".config/epiphany"  #< else it gets angry at launch
      "tmp"
    ];

    buildCost = 2;

    # XXX(2023/07/08): running on moby without `WEBKIT_DISABLE_SANDBOX...` fails, with:
    # - `bwrap: Can't make symlink at /var/run: File exists`
    # this could be due to:
    # - epiphany is somewhere following a symlink into /var/run instead of /run
    #   - (nothing in `env` or in this repo touches /var/run)
    # - no xdg-desktop-portal is installed  (unlikely)
    #
    # a few other users have hit this, in different contexts:
    # - <https://gitlab.gnome.org/GNOME/gnome-builder/-/issues/1164>
    # - <https://github.com/flatpak/flatpak/issues/3477>
    # - <https://github.com/NixOS/nixpkgs/issues/197085>
    #
    # TODO: consider `WEBKIT_USE_SINGLE_WEB_PROCESS=1` for better perf
    # - this runs all tabs in 1 process. which is fine, if i'm not a heavy multi-tabber
    packageUnwrapped = pkgs.epiphany.overrideAttrs (upstream: {
      preFixup = ''
        gappsWrapperArgs+=(
          --set WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS "1"
        );
      '' + (upstream.preFixup or "");
    });
    persist.byStore.private = [
      ".cache/epiphany"
      ".local/share/epiphany"
      # also .config/epiphany, but appears empty
    ];
    mime.priority = 200;  # default priority is 100: install epiphany only as a fallback
    mime.associations = let
      desktop = "org.gnome.Epiphany.desktop";
    in {
      "text/html" = desktop;
      "x-scheme-handler/http" = desktop;
      "x-scheme-handler/https" = desktop;
      "x-scheme-handler/about" = desktop;
      "x-scheme-handler/unknown" = desktop;
    };
    gsettings."org/gnome/epiphany" = {
      ask-for-default = false;
    };
    gsettings."org/gnome/epiphany/web" = {
      enable-adblock = true;
      # enable-itp = false;  # ??
      enable-website-data-storage = true;
      remember-passwords = false;
    };
    env.BROWSER = "epiphany";
  };
}
