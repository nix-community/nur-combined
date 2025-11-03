{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "altmount";
  version = "0.0.1-alpha4";

  src = fetchFromGitHub {
    owner = "javi11";
    repo = "altmount";
    rev = "v${version}";
    hash = "sha256-kFOz9iRyVWr26eo3tBs4izM21bhRGv2qxdl8NnP48d0=";
  };

  vendorHash = "sha256-/EJI+a9iCRecnk03Ug6MS8uyVFb1x6p9nQRYpbEhSvM=";

  subPackages = [ "cmd/altmount" ];

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Usenet virtual fs";
    homepage = "https://github.com/javi11/altmount";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "altmount";
  };
}
