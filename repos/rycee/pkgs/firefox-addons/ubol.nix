{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "ubolite";
  version = "2026.914.1325";
  addonId = "uBOLiteRedux@raymondhill.net";
  url = "https://github.com/uBlockOrigin/uBOL-home/releases/download/2026.914.1325/uBOLite_2026.914.1325.firefox.signed.xpi";
  sha256 = "38a3b9b95248b8f7c662592a73b6b805884bb8f3951b0cadaddd4a933147e169";
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
