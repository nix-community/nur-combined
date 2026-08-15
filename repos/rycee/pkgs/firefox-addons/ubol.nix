{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "ubolite";
  version = "2026.812.1211";
  addonId = "uBOLiteRedux@raymondhill.net";
  url = "https://github.com/uBlockOrigin/uBOL-home/releases/download/2026.812.1211/uBOLite_2026.812.1211.firefox.signed.xpi";
  sha256 = "aa9aff5284eac5e096f14807df6aa8a2501b53956c5a474970951ba3173d2092";
  mozPermissions = [
    "<all_urls>"
    "activeTab"
    "alarms"
    "declarativeNetRequest"
    "scripting"
    "storage"
    "unlimitedStorage"
  ];
  meta = with lib; {
    homepage = "https://github.com/uBlockOrigin/uBOL-home";
    description = "An efficient content blocker based on the MV3 API.";
    license = licenses.agpl3Plus;
    platforms = platforms.all;
  };
}
