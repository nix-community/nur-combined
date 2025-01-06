{ ... }:
{
  sane.programs.wike = {
    buildCost = 2;

    sandbox.wrapperType = "inplace";  # share/wike/wike-sp refers back to the binaries and share
    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  # without this, the search button pulls up a table of contents instead
    # default sandboxing breaks rendering in weird ways. like it loads the desktop version of articles.
    # enabling DRI/DRM (as below) hopefully fixes that.
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.extraPaths = [
      # wike sandboxes *itself* with bwrap, and dbus-proxy which, confusingly, causes it to *require* these paths.
      # TODO: these could maybe be mounted empty.
      "/sys/block"
      "/sys/bus"
      "/sys/class"
      "/sys/dev"
      "/sys/devices"
    ];
    sandbox.mesaCacheDir = ".cache/wike/mesa";  # TODO: is this the correct app-id?

    # wike probably meant to put everything here in a subdir, but didn't.
    # see: <https://github.com/hugolabe/Wike/issues/176>
    persist.byStore.ephemeral = [
      ".cache/webkitgtk"
      ".local/share/webkitgtk"
    ];
    persist.byStore.private = [
      { path=".local/share/historic.json"; type="file"; }  # history
      # .local/share/cookies (probably not necessary to persist?)

      # .local/share/booklists.json (empty; not sure if wike's)
      # .local/share/bookmarks.json (empty; not sure if wike's)
      # .local/share/languages.json (not sure if wike's)
    ];
  };
}
