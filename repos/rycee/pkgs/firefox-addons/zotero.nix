{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "zotero-connector";
  version = "5.0.199";
  addonId = "zotero@chnm.gmu.edu";
  url = "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.199.xpi";
  sha256 = "061dcf203f709b510edf803e5c401b4ef818ed286600c642c3fe9d5cc3d005ca";
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
