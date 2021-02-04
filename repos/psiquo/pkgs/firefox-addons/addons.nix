{  buildFirefoxXpiAddon, fetchurl, stdenv}:

{
  "tabliss" = buildFirefoxXpiAddon {
      pname = "tabliss";
      version = "2.1.0";
      addonId = "extension@tabliss.io";
      url = "https://addons.mozilla.org/firefox/downloads/file/3716637/tabliss_new_tab-2.1.0-fx.xpi";
      sha256 = "7381d681c4eef5bf91667e6b3918569c72009c6a7f62f9a33a44017b03d740ef";
      meta = with stdenv.lib;
        {
          homepage = "https://tabliss.io";
          description = "A beautiful New Tab page with many customisable backgrounds and widgets that does not require any permissions.";
          license = licenses.gpl3;
          platforms = platforms.all;
        };
    };
}
