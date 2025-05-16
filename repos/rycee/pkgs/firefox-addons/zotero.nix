{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:

buildFirefoxXpiAddon {
  pname = "zotero-connector";
  version = "5.0.166";
  addonId = "zotero@chnm.gmu.edu";
  url =
    "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.166.xpi";
  sha256 = "3210e1171ffce4a3ee78f0121ad026d5554fab19c53cd5e244c0576f5959ed55";
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
