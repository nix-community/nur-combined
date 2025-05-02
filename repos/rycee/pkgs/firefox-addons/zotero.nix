{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:

buildFirefoxXpiAddon {
  pname = "zotero-connector";
  version = "5.0.165";
  addonId = "zotero@chnm.gmu.edu";
  url =
    "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.165.xpi";
  sha256 = "9f85e0b1912a21bb3c7fac88b8cccc429e69a5205d41e20bea67e368c350f6fe";
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
