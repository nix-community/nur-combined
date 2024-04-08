{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:

{
  zotero-connector = buildFirefoxXpiAddon {
    pname = "zotero-connector";
    version = "5.0.123";
    addonId = "zotero@chnm.gmu.edu";
    url =
      "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.123.xpi";
    sha256 = "6d55b9e31437e0c43c356c54b46e6a8b370dece2d6ef45898238257c4aae6371";
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
  };
}
