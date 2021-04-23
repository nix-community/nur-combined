{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "ublock-origin";
  url = "https://addons.mozilla.org/firefox/downloads/file/3763753/ublock_origin-1.35.0-an+fx.xpi";
  sha256 = "sha256-dUxYFUa9Ks7JKdxpxhmgovE8ZdVEkE6JFEHn8GBGYUQ=";

  # meta = with lib; {
  #   https://github.com/gorhill/uBlock/releases/download/1.34.0/uBlock0_1.34.0.firefox.xpi
  #   homepage = "https://github.com/gorhill/uBlock/";
  #   changelog = "https://github.com/gorhill/uBlock/releases/";
  #   description = "An efficient blocker";
  #   longDescription = ''
  #     uBlock Origin is NOT an "ad blocker": it is a wide-spectrum blocker 
  #     which happens to be able to function as a mere "ad blocker".
  #     The default behavior of uBlock Origin when newly installed is to block
  #     ads, trackers and malware sites -- through EasyList, EasyPrivacy, Peter
  #     Lowe's ad/tracking/malware servers, Online Malicious URL Blocklist, and
  #     uBlockOrigin's own filter lists.
  #   '';
  #   license = licenses.gpl3;
  #   maintainers = with maintainers; [ jk ];
  # };
}
