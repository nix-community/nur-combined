{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "yggmail";
  version = "0-unstable-2025-12-20";

  src = fetchFromGitHub {
    owner = "neilalexander";
    repo = "yggmail";
    rev = "8bf3ba5f47906afc6c00bc6c7576354e007db186";
    hash = "sha256-nbk4CWll62Q2y6S7Tc6fZZWe8R6Bm82/Zp+HrT5YEPc=";
  };

  vendorHash = "sha256-4fuDl7Y0dsCy/oZFsSFIfJf91WOtFGiRpcL6bFFxyME=";

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
