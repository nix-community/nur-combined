{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "zotero-connector";
  version = "5.0.193";
  addonId = "zotero@chnm.gmu.edu";
  url = "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.193.xpi";
  sha256 = "8d02ed56415e44367c22254644a15c2796fa0277171e72ee3394d2f2f6808906";
  mozPermissions = [
    "http://*/*"
    "https://*/*"
    "tabs"
    "contextMenus"
    "cookies"
    "storage"
    "scripting"
    "webRequest"
    "webRequestBlocking"
    "webNavigation"
    "declarativeNetRequest"
    "management"
    "clipboardWrite"
  ];
  meta = with lib; {
    homepage = "https://www.zotero.org/";
    description = "Save references to Zotero from your web browser";
    license = licenses.agpl3Plus;
    platforms = platforms.all;
  };
}
