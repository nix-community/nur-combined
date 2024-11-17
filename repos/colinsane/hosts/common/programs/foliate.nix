# foliate: <https://johnfactotum.github.io/foliate/>
{ ... }:
{
  sane.programs.foliate = {
    sandbox.net = "clearnet";  #< for dictionary, wikipedia, online book libraries
    sandbox.whitelistDbus = [ "user" ];  #< when clicking on links
    sandbox.whitelistDri = true;  # reduces startup time and subjective page flip time
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Books/Books"
      "Books/local"
      "Books/servo"
      "tmp"  #< for downloaded files
    ];
    sandbox.extraPaths = [
      # foliate sandboxes itself with bwrap, which needs these.
      #   but it actually only cares that /sys/{block,bus,class/block} *exist*: it doesn't care if there's anything in them.
      #   so bind empty (sub)directories
      # and it looks like i might need to keep IPC namespace if i want TTS.
      "/sys/block/loop7"
      "/sys/bus/container/devices"
      "/sys/class/block/loop7"
    ];
    sandbox.autodetectCliPaths = "existing";

    persist.byStore.plaintext = [
      ".local/share/com.github.johnfactotum.Foliate"  #< books added, reading position
      ".cache/com.github.johnfactotum.Foliate"  #< webkit cache
    ];

    buildCost = 2;  #< webkitgtk 6.0
    # these associations were taken from its .desktop file
    mime.associations."application/epub+zip" = "com.github.johnfactotum.Foliate.desktop";
    mime.associations."application/x-mobipocket-ebook" = "com.github.johnfactotum.Foliate.desktop";
    mime.associations."application/vnd.amazon.mobi8-ebook" = "com.github.johnfactotum.Foliate.desktop";
    mime.associations."application/x-fictionbook+xml" = "com.github.johnfactotum.Foliate.desktop";
    mime.associations."application/x-zip-compressed-fb2" = "com.github.johnfactotum.Foliate.desktop";
    mime.associations."application/vnd.comicbook+zip" = "com.github.johnfactotum.Foliate.desktop";  # .cbz
    mime.associations."x-scheme-handler/opds" = "com.github.johnfactotum.Foliate.desktop";
    mime.priority = 120;  #< default is 100; fallback to more specialized cbz handlers, e.g., but keep specializations for epub
  };
}
