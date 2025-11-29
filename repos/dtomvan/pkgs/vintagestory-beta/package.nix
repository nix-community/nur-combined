{ vintagestory, fetchzip, ... }:
vintagestory.overrideAttrs rec {
  version = "1.21.6-rc.1";
  src = fetchzip {
    url = "https://cdn.vintagestory.at/gamefiles/unstable/vs_client_linux-x64_${version}.tar.gz";
    hash = "sha256-4fHSKAv0ISzVXSgdNmrr2dWDWzqrPOXvm4QMCfa+cYE=";
  };
}
