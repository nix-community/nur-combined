{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:

buildFirefoxXpiAddon {
  pname = "zotero-connector";
  version = "5.0.141";
  addonId = "zotero@chnm.gmu.edu";
  url =
    "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.141.xpi";
  sha256 = "407125d7bd938ec75658233eb8ef15a4b40cad14bf64d1405a23eb0ce2e4d5b4";
  mozPermissions = [
    "http://*/*"
    "https://*/*"
    "tabs"
    "contextMenus"
    "cookies"
    "webRequest"
    "webRequestBlocking"
    "webNavigation"
    "storage"
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
