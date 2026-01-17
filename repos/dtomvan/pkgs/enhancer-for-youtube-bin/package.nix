{
  lib,
  fetchurl,
  callPackage,
  buildFirefoxXpiAddon ? callPackage ../../lib/buildFirefoxXpiAddon.nix { },
}:
buildFirefoxXpiAddon {
  pname = "enhancer-for-youtube";
  version = "0-rip";

  src = fetchurl {
    url = "https://www.mrfdev.com/downloads/enhancer_for_youtube-2.0.130.1.xpi";
    hash = "sha256-bYTcupsZeED0hdZtP9Q1J51uG80hVdKDiZmeh+oBMSw=";
  };

  addonId = "enhancerforyoutube@maximerf.addons.mozilla.org";

  meta = with lib; {
    homepage = "https://www.mrfdev.com/enhancer-for-youtube";
    description = "Take control of YouTube and boost your user experience!";
    license = lib.licenses.unfreeRedistributable;
    mozPermissions = [
      "cookies"
      "storage"
      "*://www.youtube.com/*"
      "*://www.youtube.com/embed/*"
      "*://www.youtube.com/live_chat*"
      "*://www.youtube.com/pop-up-player/*"
      "*://www.youtube.com/shorts/*"
    ];
    platforms = platforms.all;
  };
}
