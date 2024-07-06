{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:

buildFirefoxXpiAddon {
  pname = "zotero-connector";
  version = "5.0.140";
  addonId = "zotero@chnm.gmu.edu";
  url =
    "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.140.xpi";
  sha256 = "357c808b16d80c4da7f406af221209f477f1e40a61046cec083d94f148c0d4a7";
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
