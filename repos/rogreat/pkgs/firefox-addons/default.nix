{ buildMozillaXpiAddon, fetchurl, lib, stdenv }:
  {
    "livemarks" = buildMozillaXpiAddon {
      pname = "livemarks";
      version = "3.9";
      addonId = "{c5867acc-54c9-4074-9574-04d8818d53e8}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4918963/livemarks-3.9.xpi";
      sha256 = "fe5b1ef51fe88b2157c5010c53c468351460b315a84456fec0310d7c28994b7f";
      meta = with lib;
      {
        homepage = "https://github.com/nt1m/livemarks/";
        description = "Get auto-updated RSS feed bookmark folders.";
        license = licenses.mit;
        mozPermissions = [
          "storage"
          "bookmarks"
          "history"
          "webRequest"
          "webRequestBlocking"
          "<all_urls>"
          "tabs"
          "menus"
          "http://*/*"
          "https://*/*"
        ];
        platforms = platforms.all;
      };
    };
    "soundfixer" = buildMozillaXpiAddon {
      pname = "soundfixer";
      version = "1.4.1";
      addonId = "soundfixer@unrelenting.technology";
      url = "https://addons.mozilla.org/firefox/downloads/file/4205769/soundfixer-1.4.1.xpi";
      sha256 = "b229c77635e4e89ab586144aea2fcc977a2c5e51509a84ac884fa59e29ee7792";
      meta = with lib;
      {
        homepage = "https://github.com/valpackett/soundfixer";
        description = "Helps you fix annoying sound problems on sites like YouTube: audio in one channel only, too quiet or too loud.\n\n(Unfortunately, this extension does not work on all websites because of cross-domain issues — but it does work on YouTube!)";
        license = licenses.unlicense;
        mozPermissions = [ "activeTab" "webNavigation" ];
        platforms = platforms.all;
      };
    };
  }