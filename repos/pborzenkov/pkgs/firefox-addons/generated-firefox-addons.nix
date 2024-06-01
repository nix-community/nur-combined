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
        mozPermissions = [ "<all_urls>" "tabs" "storage" "bookmarks" ];
        platforms = platforms.all;
        };
      };
    }