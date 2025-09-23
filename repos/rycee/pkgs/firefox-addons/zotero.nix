{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "zotero-connector";
  version = "5.0.182";
  addonId = "zotero@chnm.gmu.edu";
  url = "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.182.xpi";
  sha256 = "afe0367333c4bd4e224439d83bddd55dce9fde7f2bf6104fd805d6f370460cc4";
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
