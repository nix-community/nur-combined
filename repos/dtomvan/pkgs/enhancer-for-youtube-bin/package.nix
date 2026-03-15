{
  lib,
  fetchurl,
  callPackage,
  buildFirefoxXpiAddon ? callPackage ../../lib/buildFirefoxXpiAddon.nix { },
}:
buildFirefoxXpiAddon rec {
  pname = "enhancer-for-youtube";
  version = "2.0.132";

  src = fetchurl {
    url = "https://addons.mozilla.org/firefox/downloads/file/4693280/enhancer_for_youtube-${version}.xpi";
    hash = "sha256-PNJzpjJmz+mmI9zznOXaFw6XDLMoTWMnauTtGOjA9PA=";
  };

  addonId = "enhancerforyoutube@maximerf.addons.mozilla.org";

  meta = {
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
    platforms = lib.platforms.all;
  };
}
