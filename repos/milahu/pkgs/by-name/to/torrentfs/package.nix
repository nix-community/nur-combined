{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "torrentfs";
  version = "1.0.72";

  src = fetchFromGitHub {
    owner = "CortexFoundation";
    repo = "torrentfs";
    rev = "v${version}";
    hash = "sha256-vPx6GUmcxuQkCkAKwkwdZbozD+bRoJo63HVzUXRNVzY=";
  };

  vendorHash = "sha256-oY2OAZnN9Nv+opJIHTP31b8Aw+0H66RgcRcrk5wfYTA=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "A p2p file system for https://github.com/CortexFoundation/CortexTheseus with pure Golang";
    homepage = "https://github.com/CortexFoundation/torrentfs";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "torrentfs";
  };
}
