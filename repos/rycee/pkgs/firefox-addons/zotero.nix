{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "zotero-connector";
  version = "5.0.189";
  addonId = "zotero@chnm.gmu.edu";
  url = "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.189.xpi";
  sha256 = "2a47092283449c0d99e8b2945b7c60e0b8957ba8113bd14ed40cef7e48d68dcc";
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
