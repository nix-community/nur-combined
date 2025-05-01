{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:

buildFirefoxXpiAddon {
  pname = "zotero-connector";
  version = "5.0.164";
  addonId = "zotero@chnm.gmu.edu";
  url =
    "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.164.xpi";
  sha256 = "e9758488381394bf235be9cb317a80b5937a76f619caa65319412745937edfdb";
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
