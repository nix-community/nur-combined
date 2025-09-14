{ vintagestory, fetchzip, ... }:
vintagestory.overrideAttrs rec {
  version = "1.21.1-rc.2";
  src = fetchzip {
    url = "https://cdn.vintagestory.at/gamefiles/unstable/vs_client_linux-x64_${version}.tar.gz";
    hash = "sha256-mSYcwWTlTmiM1/tI2iecqZIwPIdR3Rxqda4rwE1COho=";
  };
}
