{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "ubolite";
  version = "2026.529.1448";
  addonId = "uBOLiteRedux@raymondhill.net";
  url = "https://github.com/uBlockOrigin/uBOL-home/releases/download/2026.529.1448/uBOLite_2026.529.1448.firefox.signed.xpi";
  sha256 = "798a224b37040d2f0d336659cae4816915954f5889d7c11cc0be3d970f3b1d52";
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
