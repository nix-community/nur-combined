{ lib, buildFirefoxXpiAddon, ... }:

let
  version = "2.0";
in
buildFirefoxXpiAddon {
  pname = "mousevaderv2";
  inherit version;
  addonId = "{28b96d01-2454-40c9-be79-7976882e259d}";
  url =
    "https://addons.mozilla.org/firefox/downloads/file/4202802/mousevaderv2-${version}.xpi";
  sha256 = "sha256-dSurrjvrznzCMHdCuMHtEQ9hCy+FTu74hvRBXK8GNbU=";
  meta = with lib; {
    homepage =
      "https://addons.mozilla.org/en-US/firefox/addon/mousevaderv2/";
    description = "A tool that misleads dashboard inactivity detections";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
