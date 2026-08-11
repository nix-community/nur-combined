{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "confluence";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "anacrolix";
    repo = "confluence";
    rev = "v${version}";
    hash = "sha256-IcDggL/OMSncQxmda1R5Zg0ZG48BnEdzFOXmcPjETOg=";
  };

  vendorHash = "sha256-YyWA5xd1W9CKFd+iObkN6zD2fzsLO8ibK8mAEDaj7rA=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Torrent client as a HTTP service";
    homepage = "https://github.com/anacrolix/confluence";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "confluence";
  };
}
