{ lib, buildFirefoxXpiAddon, ... }:

let
  version = "1.2";
in
buildFirefoxXpiAddon {
  pname = "mousevader";
  inherit version;
  addonId = "{ca68687b-3485-4894-b39c-15480de86a56}";
  url =
    "https://addons.mozilla.org/firefox/downloads/file/3982514/mousevader-${version}.xpi";
  sha256 = "sha256-bDlU2D+ySMn20VlUf7LYjZib8EnB/zFHyntvFMeNhPM=";
  meta = with lib; {
    homepage =
      "https://github.com/fadyanwar/MouseVader";
    description = "A privacy tool that misleads trackers by creating noise";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
