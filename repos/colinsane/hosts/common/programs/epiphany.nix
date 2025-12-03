# epiphany web browser
# - GTK4/webkitgtk
#
# usability notes:
# - touch-based scroll works well (for moby)
# - URL bar constantly resets cursor to the start of the line as i type
#   - maybe due to the URLbar suggestions getting in the way
#
# TODO: consider wrapping with `WEBKIT_USE_SINGLE_WEB_PROCESS=1` for better perf
# - this runs all tabs in 1 process. which is fine, if i'm not a heavy multi-tabber
{ lib, ... }:
{
  sane.programs.epiphany = {
    sandbox.wrapperType = "inplace";  # /share/epiphany/default-bookmarks.rdf refers back to /share; dbus files to /libexec
    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user = true;  #< TODO: reduce. requires to support nested dbus proxy though.
    # sandbox.whitelistDbus.user.own = [ "org.gnome.Epiphany" ];
    # sandbox.whitelistPortal = [
    #   # these are all speculative
    #   "Camera"
    #   "FileChooser"
    #   "Location"
    #   "OpenURI"
    #   "Print"
    #   "ProxyResolver"  #< required else it doesn't load websites
    #   "ScreenCast"
    # ];

    # default sandboxing breaks rendering in weird ways. sites are super zoomed in / not scaled.
    # enabling DRI/DRM (as below) seems to fix that.
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      ".config/epiphany"  #< else it gets angry at launch
      "tmp"
    ];
    sandbox.extraPaths = [
      # epiphany sandboxes *itself* with bwrap, and dbus-proxy which, confusingly, causes it to *require* these paths.
      # TODO: these could maybe be mounted empty.
      "/sys/block"
      "/sys/bus"
      "/sys/class"
    ];

    buildCost = 2;

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
    gsettings."org/gnome/epiphany" = with lib.gvariant; {
      ask-for-default = false;
      # homepage-url = "about:newtab";
      search-engine-providers = [
        # [
        #   (mkDictionaryEntry "url" (mkVariant "https://www.bing.com/search?q=%s"))
        #   (mkDictionaryEntry "bang" (mkVariant "!b"))
        #   (mkDictionaryEntry "name" (mkVariant "Bing"))
        # ]
        [
          (mkDictionaryEntry "url" (mkVariant "https://duckduckgo.com/?q=%s&t=epiphany&kd=-1"))
          (mkDictionaryEntry "bang" (mkVariant "!ddg"))
          (mkDictionaryEntry "name" (mkVariant "DuckDuckGo"))
        ]
        [
          # serializes to: {'url': <'https://www.google.com/search?q=%s'>, 'bang': <'!g'>, 'name': <'Google'>},
          (mkDictionaryEntry "url" (mkVariant "https://www.google.com/search?q=%s"))
          (mkDictionaryEntry "bang" (mkVariant "!g"))
          (mkDictionaryEntry "name" (mkVariant "Google"))
        ]
        [
          (mkDictionaryEntry "url" (mkVariant "https://kagi.com/search?q=%s"))
          (mkDictionaryEntry "bang" (mkVariant "!k"))
          (mkDictionaryEntry "name" (mkVariant "Kagi"))
        ]
      ];
      default-search-engine = "Kagi";
    };
    gsettings."org/gnome/epiphany/web" = {
      # default-zoom-level = 1.0;
      enable-adblock = true;
      # enable-itp = false;  # ??
      # enable-popups = true;
      enable-website-data-storage = true;
      remember-passwords = false;
    };
    env.BROWSER = "epiphany";
  };
}
