{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "ubolite";
  version = "2026.607.1724";
  addonId = "uBOLiteRedux@raymondhill.net";
  url = "https://github.com/uBlockOrigin/uBOL-home/releases/download/2026.607.1724/uBOLite_2026.607.1724.firefox.signed.xpi";
  sha256 = "6385a07aecc40d5a8b40ece7cc73292635105247a37514201f577b604d1791c9";
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
