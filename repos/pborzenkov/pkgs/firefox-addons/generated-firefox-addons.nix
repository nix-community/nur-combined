{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "shiori_ext" = buildFirefoxXpiAddon {
      pname = "shiori_ext";
      version = "1.8.0.1";
      addonId = "{c6e8bd66-ebb4-4b63-bd29-5ef59c795903}";
      url = "https://addons.mozilla.org/firefox/downloads/file/4588202/shiori_ext-1.8.0.1.xpi";
      sha256 = "0ad6fc8d97ac2b587daf354f8c80e024f2f97e4a92b67c08ff40399416ef3de7";
      meta = with lib;
      {
        homepage = "https://github.com/go-shiori/shiori-web-ext";
        description = "Web extension for Shiori, a simple bookmark manager.\nSource code: https://github.com/go-shiori/shiori, https://github.com/go-shiori/shiori-web-ext";
        license = licenses.mit;
        mozPermissions = [
          "tabs"
          "storage"
          "bookmarks"
          "scripting"
          "activeTab"
          "<all_urls>"
        ];
        platforms = platforms.all;
      };
    };
  }