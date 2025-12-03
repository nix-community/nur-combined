{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "cloud-torrent";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "jpillora";
    repo = "cloud-torrent";
    rev = "v${version}";
    hash = "sha256-KlHVCSRTXuBHyCFPR/huspnthQnF6YT/F6zpsl+ca50=";
  };

  vendorHash = "sha256-o5nZCDpNXMzjV7EnSpWjOFYDsnSFVEjZtAzn9jKPA0I=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Cloud Torrent: a self-hosted remote torrent client";
    homepage = "https://github.com/jpillora/cloud-torrent";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "cloud-torrent";
  };
}
