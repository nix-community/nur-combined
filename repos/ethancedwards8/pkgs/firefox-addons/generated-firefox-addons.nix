{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:

{
  "nextcloud-passwords" = buildFirefoxXpiAddon {
    pname = "nextcloud-passwords";
    version = "2.1.1";
    addonId = "{dd3f1df1-603a-471e-8222-44ffa40e73f9}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3734590/passwords_for_nextcloud_browser_add_on-2.1.1-an+fx.xpi";
    sha256 = "PeRuWWTUP619a17CoEUCgBWceYn022pdIfLKJrmnXqk=";
    meta = with lib;
    {
      homepage = "https://github.com/marius-wieschollek/passwords-webextension";
      description = "The official browser extension for the Passwords app for Nextcloud.";
      license = licenses.gpl3Plus;
      platforms = platforms.all;
    };
  };

  "sponsorblock" = buildFirefoxXpiAddon {
    pname = "sponsorblock";
    version = "2.0.13.1";
    addonId = "{e971a746-0c3e-449a-8d8c-0594d710bc19}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3748692/sponsorblock_skip_sponsorships_on_youtube-2.0.13.1-an+fx.xpi";
    sha256 = "yZkIEtN2r7YHxDe/smGE57Pwe8/AEWpaRcphfG0/BFM=";
    meta = with lib;
    {
      homepage = "https://sponsor.ajay.app/";
      description = "Easily skip YouTube video sponsors. When you visit a YouTube video, the extension will check the database for reported sponsors and automatically skip known sponsors. You can also report sponsors in videos.";
      license = licenses.gpl3;
      platforms = platforms.all;
    };
  };

  "enhancer-for-youtube" = buildFirefoxXpiAddon {
    pname = "enhancer-for-youtube";
    version = "2.0.103.3";
    addonId = "{7aabc7b4-8e54-4d21-af11-f1f0774bda7c}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3738131/enhancer_for_youtubetm-2.0.103.3-fx.xpi";
    sha256 = "QcMdo0qZ+uXZ/L3cV/RxXxxD5jm2iK5PZlECWW+mkLU=";
    meta = with lib;
    {
      homepage = "https://www.mrfdev.com/enhancer-for-youtube";
      description = "Take control of YouTube and boost your user experience!";
      license = {
        shortName = "clefy";
        fullName = "Custom License for Enhancer for YouTube";
        url = "https://addons.mozilla.org/en-US/firefox/addon/enhancer-for-youtube/license/";
        free = false;
      };
      platforms = platforms.all;
    };
  };
}
