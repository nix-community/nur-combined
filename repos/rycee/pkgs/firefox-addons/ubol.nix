{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "ubolite";
  version = "2026.723.1724";
  addonId = "uBOLiteRedux@raymondhill.net";
  url = "https://github.com/uBlockOrigin/uBOL-home/releases/download/2026.723.1724/uBOLite_2026.723.1724.firefox.signed.xpi";
  sha256 = "2568f11f7e85d1a3b2f0810a064f716b04ff6ee8da3fabaa422ea54939126a83";
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
