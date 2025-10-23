{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "zotero-connector";
  version = "5.0.186";
  addonId = "zotero@chnm.gmu.edu";
  url = "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.186.xpi";
  sha256 = "cc8d75af6caa9c59ec1ddc585fc9d646864d35dcf5548d2b94bbdb149e1545d1";
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
