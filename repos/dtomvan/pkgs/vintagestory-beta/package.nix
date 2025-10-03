{ vintagestory, fetchzip, ... }:
vintagestory.overrideAttrs rec {
  version = "1.21.2-rc.3";
  src = fetchzip {
    url = "https://cdn.vintagestory.at/gamefiles/unstable/vs_client_linux-x64_${version}.tar.gz";
    hash = "sha256-bso5NwzDhtaZJdlR8LbaLtOM5WckirEtYwM+r1F7GYY=";
  };
}
