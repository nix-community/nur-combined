{ buildFirefoxXpiAddon, fetchurl, stdenv }:
{
  "darkreader" = buildFirefoxXpiAddon {
    pname = "darkreader";
    version = "4.9.24";
    addonId = "addon@darkreader.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/3680957/dark_reader-4.9.24-an+fx.xpi";
    sha256 = "4d8c220167819e21347213635930c1b866dc73d8943cf1cef94d6aa2eaf0ddf1";
    meta = with stdenv.lib;
      {
        homepage = "https://darkreader.org/";
        description = "Dark mode for every website. Take care of your eyes, use dark theme for night and daily browsing.";
        license = licenses.mit;
        platforms = platforms.all;
      };
  };
  "enhancer-for-youtube" = buildFirefoxXpiAddon {
    pname = "enhancer-for-youtube";
    version = "2.0.101";
    addonId = "enhancerforyoutube@maximerf.addons.mozilla.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/3537917/enhancer_for_youtubetm-2.0.101-fx.xpi";
    sha256 = "b64c2f36b6fc93c22d2305bb25dd0af60c5f3d1fa7ce45592ba3344aa2a99715";
    meta = with stdenv.lib;
      {
        homepage = "https://www.mrfdev.com/enhancer-for-youtube";
        description = "Tons of features to improve your user experience on YouTube™.";
        platforms = platforms.all;
      };
  };
}
