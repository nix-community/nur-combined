{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "ubolite";
  version = "2026.301.2014";
  addonId = "uBOLiteRedux@raymondhill.net";
  url = "https://github.com/uBlockOrigin/uBOL-home/releases/download/2026.301.2014/uBOLite_2026.301.2014.firefox.signed.xpi";
  sha256 = "23d42b4a595dd71d18e8d281b17fc65eb9d09b67038ce05736fccf6b6c66b468";
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
