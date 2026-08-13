{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "ubolite";
  version = "2026.811.1529";
  addonId = "uBOLiteRedux@raymondhill.net";
  url = "https://github.com/uBlockOrigin/uBOL-home/releases/download/2026.811.1529/uBOLite_2026.811.1529.firefox.signed.xpi";
  sha256 = "23a6f93240b8c1f0d41c80c8099c65c97a829f66754eb4aa316d53ccc73cbd9c";
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
