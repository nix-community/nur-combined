{
  lib,
  fetchFromGitHub,
  buildGoModule,
  unstableGitUpdater,
}:

buildGoModule {
  pname = "telemikiya";
  version = "0-unstable-2025-03-05";

  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "TeleMikiya";
    rev = "dc2875d2ab78daf7fcb241b9d9812f10891f459a";
    hash = "sha256-6s7GFhgqp0EGKPRCkAtYBUfdeFhTyMLBEwZtheHhYtE=";
  };

  vendorHash = "sha256-Y8GwezxVOx9Z66vs0Hvj6ybxi3PMnCwwHZNVvTIEGSo=";

  subPackages = [ "." ];
  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    mainProgram = "telemikiya";
    description = "Hybrid message search tool for Telegram";
    homepage = "https://github.com/XYenon/TeleMikiya";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xyenon ];
  };
}
