{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "ubolite";
  version = "2026.329.1951";
  addonId = "uBOLiteRedux@raymondhill.net";
  url = "https://github.com/uBlockOrigin/uBOL-home/releases/download/2026.329.1951/uBOLite_2026.329.1951.firefox.signed.xpi";
  sha256 = "e458cf23bbb6415e37701885fc325cdf3adbfe10143f4b2c2213f670609679cb";
  mozPermissions = [
    "<all_urls>"
    "activeTab"
    "declarativeNetRequest"
    "scripting"
    "storage"
  ];
  meta = with lib; {
    homepage = "https://github.com/uBlockOrigin/uBOL-home";
    description = "An efficient content blocker based on the MV3 API.";
    license = licenses.agpl3Plus;
    platforms = platforms.all;
  };
}
