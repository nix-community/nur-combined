{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "wallabagger" = buildFirefoxXpiAddon {
      pname = "wallabagger";
      version = "1.15.0";
      addonId = "{7a7b1d36-d7a4-481b-92c6-9f5427cb9eb1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4055568/wallabagger-1.15.0.xpi";
      sha256 = "d6980b65daa5ca746a7b6a9b7ef5f5c228ae99ca2d9e3c1c06041fd43489fc6f";
      meta = with lib;
      {
        homepage = "https://github.com/wallabag/wallabagger";
        description = "This wallabag v2 extension has the ability to edit title and tags and set starred, archived, or delete states.\nYou can add a page from the icon or through the right click menu on a link or on a blank page spot.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    }