{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "yggmail";
  version = "0-unstable-2026-02-24";

  src = fetchFromGitHub {
    owner = "neilalexander";
    repo = "yggmail";
    rev = "aa1c8c72fc2a73a8eb4cb667ec37062bc3ffc29f";
    hash = "sha256-lhOLNFH6aZSFQTtxkFZLGNvYiWE/2n6K6/AkgiYmCJ8=";
  };

  vendorHash = "sha256-Lm3xgMLVaUyXgxjsjkd5PopVbKWKKvsSovNd2AeCA18=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "End-to-end encrypted email for the mesh networking age";
    homepage = "https://github.com/neilalexander/yggmail";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "yggmail";
  };
}
