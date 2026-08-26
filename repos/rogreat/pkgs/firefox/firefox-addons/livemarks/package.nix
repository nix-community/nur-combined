{
  buildMozillaXpiAddon,
  lib,
}:

buildMozillaXpiAddon {
  pname = "livemarks";
  version = "3.9";
  addonId = "{c5867acc-54c9-4074-9574-04d8818d53e8}";
  url = "https://addons.mozilla.org/firefox/downloads/file/4918963/livemarks-3.9.xpi";
  sha256 = "sha256-/lse9R/oiyFXxQEMU8RoNRRgsxWoRFb+wDENfCiZS38=";
  meta = with lib; {
    homepage = "https://github.com/nt1m/livemarks";
    description = "Extension that restores RSS Feed Livemarks in Firefox";
    license = licenses.mit;
    mozPermissions = [
      "<all_urls>"
      "bookmarks"
      "history"
      "menus"
      "storage"
      "tabs"
      "webRequest"
      "webRequestBlocking"
    ];
    platforms = platforms.all;
  };
}
