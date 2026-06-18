{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "ubolite";
  version = "2026.614.1502";
  addonId = "uBOLiteRedux@raymondhill.net";
  url = "https://github.com/uBlockOrigin/uBOL-home/releases/download/2026.614.1502/uBOLite_2026.614.1502.firefox.signed.xpi";
  sha256 = "d967996769777dac31a8fdada4157929b11c054c90393f41ff45ca1e414b18f5";
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
