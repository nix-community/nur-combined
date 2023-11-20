{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "shiori_ext" = buildFirefoxXpiAddon {
      pname = "shiori_ext";
      version = "0.8.5";
      addonId = "{c6e8bd66-ebb4-4b63-bd29-5ef59c795903}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3911467/shiori_ext-0.8.5.xpi";
      sha256 = "6a34469437f32a99366fd26259e2ca7401f76266fb3356f833de60d1399a6a4b";
      meta = with lib;
      {
        homepage = "https://github.com/go-shiori/shiori-web-ext";
        description = "Web extension for Shiori, a simple bookmark manager.\nSource code: <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/f665bd935533eb5705b9b5a9b66fa6bf85948f0d63dc51251ce6bcbb57366666/https%3A//github.com/go-shiori/shiori\" rel=\"nofollow\">https://github.com/go-shiori/shiori</a>, <a href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/47f5664568166259ecbd623f26626113f4386ff691306c50bcbfef3030f2504b/https%3A//github.com/go-shiori/shiori-web-ext\" rel=\"nofollow\">https://github.com/go-shiori/shiori-web-ext</a>";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    "wallabagger" = buildFirefoxXpiAddon {
      pname = "wallabagger";
      version = "1.16.0";
      addonId = "{7a7b1d36-d7a4-481b-92c6-9f5427cb9eb1}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4099784/wallabagger-1.16.0.xpi";
      sha256 = "79859faf6ef0050df74e588184c34f1384e44d91310c1871404698cb6b8e4049";
      meta = with lib;
      {
        homepage = "https://github.com/wallabag/wallabagger";
        description = "This wallabag v2 extension has the ability to edit title and tags and set starred, archived, or delete states.\nYou can add a page from the icon or through the right click menu on a link or on a blank page spot.";
        license = licenses.mit;
        platforms = platforms.all;
        };
      };
    }