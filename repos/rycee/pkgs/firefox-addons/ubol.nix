{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "ubolite";
  version = "2026.901.1442";
  addonId = "uBOLiteRedux@raymondhill.net";
  url = "https://github.com/uBlockOrigin/uBOL-home/releases/download/2026.901.1442/uBOLite_2026.901.1442.firefox.signed.xpi";
  sha256 = "7b8ad065ebb0ddf8eb51138ca5cd0048b65ad41bdb6c468c87091506802f1b2f";
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
