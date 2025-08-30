{
  lib,
  callPackage,
  buildFirefoxXpiAddon ? callPackage ../../lib/buildFirefoxXpiAddon.nix { },
}:
buildFirefoxXpiAddon rec {
  pname = "enhancer-for-youtube";
  version = "0-rip";

  src = ./addon.xpi;

  addonId = "enhancerforyoutube@maximerf.addons.mozilla.org";

  meta = with lib; {
    homepage = "https://www.mrfdev.com/enhancer-for-youtube";
    description = "Take control of YouTube and boost your user experience!";
    license = {
      shortName = "enhancer-for-youtube";
      fullName = "Custom License for Enhancer for YouTube™";
      url = "https://addons.mozilla.org/en-US/firefox/addon/enhancer-for-youtube/license/";
      free = false;
    };
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
