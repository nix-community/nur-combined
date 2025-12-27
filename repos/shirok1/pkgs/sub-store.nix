{
  lib,
  stdenvNoCC,
  fetchurl,
  fetchzip,
  nodejs_22,
  writeShellApplication,
  symlinkJoin,
}:

let
  subStoreVersion = "2.20.58";
  frontEndVersion = "2.15.85";

  bundle = fetchurl {
    url = "https://github.com/sub-store-org/Sub-Store/releases/download/${subStoreVersion}/sub-store.bundle.js";
    sha256 = "sha256-13PRQjFuSb42f55HwqCnuL4VKXEmETJ8Es9VHwv2H/Q=";
  };

  frontend = fetchzip {
    name = "sub-store-frontend";
    url = "https://github.com/sub-store-org/Sub-Store-Front-End/releases/download/${frontEndVersion}/dist.zip";
    sha256 = "sha256-x3iAeLYP04hGaSYeYVCI/Q6NxGiS2VTbT0A7Amck6t4=";
  };
in
writeShellApplication {
  name = "sub-store";

  text = ''
    DATA_DIR="''${SUB_STORE_DATA_DIR:-''${STATE_DIR:-/var/lib/sub-store}}"

    mkdir -p "$DATA_DIR"
    cd "$DATA_DIR"

    export SUB_STORE_DOCKER=true
    export SUB_STORE_FRONTEND_PATH="${frontend}"
    export SUB_STORE_DATA_BASE_PATH="$DATA_DIR"

    exec ${nodejs_22}/bin/node "${bundle}"
  '';

  meta = with lib; {
    description = "Sub-Store bundle (node) + front-end dist, with clean wrapper";
    platforms = platforms.linux;
    mainProgram = "sub-store";
    license = licenses.agpl3Plus;
  };
}
