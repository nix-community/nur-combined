{ buildFirefoxXpiAddon, fetchurl, stdenv }:
{
  "darkreader" = buildFirefoxXpiAddon {
    pname = "darkreader";
    version = "4.9.23";
    addonId = "addon@darkreader.org";
    url = "https://addons.mozilla.org/firefox/downloads/file/3667405/dark_reader-4.9.23-an+fx.xpi";
    sha256 = "bb063bbc1c098a1629711bf1d4c7cd96851c7fce14c327dcef296807f25f2c32";
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
