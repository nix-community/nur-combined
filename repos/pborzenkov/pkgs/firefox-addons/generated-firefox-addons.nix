{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "wallabagger" = buildFirefoxXpiAddon {
      pname = "wallabagger";
      version = "1.13.0";
      addonId = "{7a7b1d36-d7a4-481b-92c6-9f5427cb9eb1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3782259/wallabagger-1.13.0-an+fx.xpi";
      sha256 = "67e41ee14c2e86334a8ebeb784727359fa159f3295b912693fd920f2f9f312f0";
      meta = with lib;
      {
        homepage = "https://github.com/wallabag/wallabagger";
        description = "This wallabag v2 extension has the ability to edit title and tags and set starred, archived, or delete states.\nYou can add a page from the icon or through the right click menu on a link or on a blank page spot.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    }