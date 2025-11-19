{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
  {
    "adguard-adblocker" = buildFirefoxXpiAddon {
      pname = "adguard-adblocker";
      version = "5.2.113.0";
      addonId = "adguardadblocker@adguard.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4619486/adguard_adblocker-5.2.113.0.xpi";
      sha256 = "77cf51689cd7259d0d13e96d530b8dda1c3247dae3060b39f8d11902e67b4696";
      meta = with lib;
      {
        homepage = "https://adguard.com/";
        description = "Unmatched adblock extension against advertising and pop-ups. Blocks ads on Facebook, Youtube and all other websites.";
        license = licenses.lgpl3;
        mozPermissions = [
          "tabs"
          "<all_urls>"
          "webRequest"
          "webRequestBlocking"
          "webNavigation"
          "storage"
          "contextMenus"
          "cookies"
          "privacy"
          "http://*/*"
          "https://*/*"
          "*://*.adguard.com/*/thankyou.html*"
          "*://*.adguard.info/*/thankyou.html*"
          "*://*.adguard.app/*/thankyou.html*"
        ];
        platforms = platforms.all;
      };
    };
    "calilay" = buildFirefoxXpiAddon {
      pname = "calilay";
      version = "0.41.9";
      addonId = "{e2502f98-8bf2-11df-ade1-000c290539ce}";
      url = "https://addons.mozilla.org/firefox/downloads/file/3731516/calilay-0.41.9.xpi";
      sha256 = "5bfbeb1f20276513ea8f92a74f4a53ebc078f9d6727d40b99b4f53b06f30a8bd";
      meta = with lib;
      {
        homepage = "http://sites.google.com/site/calilay/";
        description = "This can be used only in Japan.";
        license = licenses.bsd2;
        mozPermissions = [
          "tabs"
          "storage"
          "https://calil.jp/"
          "https://api.calil.jp/"
          "http://mediamarker.net/u/*"
          "http://www.amazon.co.jp/*"
          "https://www.amazon.co.jp/*"
          "https://bookmeter.com/*"
        ];
        platforms = platforms.all;
      };
    };
    "kiseppe-price-chart-kindle" = buildFirefoxXpiAddon {
      pname = "kiseppe-price-chart-kindle";
      version = "2.0.11";
      addonId = "kiseppe_ff@example.com";
      url = "https://addons.mozilla.org/firefox/downloads/file/4557993/kiseppe_price_chart_kindle-2.0.11.xpi";
      sha256 = "3ac33d68ba64386d55dd35e40eba019db6cb47ed1c67107b90de108822d66031";
      meta = with lib;
      {
        homepage = "https://yapi.ta2o.net/kndlsl/kiseppe/";
        description = "キンドル書籍ページに価格推移グラフや割引情報を表示するブラウザ拡張機能\n\nDisplays price trends, discounts, and summary links for sales on Amazon Japan's Kindle pages. Only operates on www.amazon.co.jp.";
        license = licenses.mit;
        mozPermissions = [ "storage" "https://www.amazon.co.jp/*" ];
        platforms = platforms.all;
      };
    };
  }