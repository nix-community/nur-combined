{ buildFirefoxXpiAddon, lib }:
{
  "c-c-search-extension" = buildFirefoxXpiAddon {
    pname = "c-c-search-extension";
    version = "0.2.0";
    addonId = "{e737d9cb-82de-4f23-83c6-76f70a82229c}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3718138/cc_search_extension-0.2.0-fx.xpi";
    sha256 = "7dc4ddd1bbb46a61bb4cea71baa72be55a34b84b7406d34b4cdcc88c7708b9b0";
    meta = with lib;
    {
      homepage = "https://cpp.extension.sh";
      description = "The ultimate search extension for C/C++";
      license = licenses.asl20;
      platforms = platforms.all;
    };
  };

  "js-search-extension" = buildFirefoxXpiAddon {
    pname = "js-search-extension";
    version = "0.1";
    addonId = "{479ec4ee-fd16-4f95-b172-dd39fbd921ad}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3718212/js_search_extension-0.1-fx.xpi";
    sha256 = "07d68e168d7137434cf5096efed581daa836a31096b0ca3f39a76a58e08b3ff5";
    meta = with lib;
    {
      homepage = "https://js.extension.sh";
      description = "The ultimate search extension for Javascript!";
      license = licenses.asl20;
      platforms = platforms.all;
    };
  };

    "wwweed" = buildFirefoxXpiAddon {
      pname = "wwweed";
      version = "2021.12.11";
      addonId = "extension-id@wwweed";
      url = "https://gitdab.com/attachments/0c7cf19a-e0e0-494d-8875-e12286f1cb35";
      sha256 = "1m5jbcmdyyrz7p32rq4mnclmn84wn26xkx10044d9ys86348m5p3";
      meta = with lib;
      {
        homepage = "https://gitdab.com/elle/wwweed";
        description = "My personal start page";
        license = licenses.unlicense;
        platforms = platforms.all;
      };
    };
  }

