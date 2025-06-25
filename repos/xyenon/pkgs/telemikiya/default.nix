{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  go,
}:

buildGoModule {
  pname = "telemikiya";
  version = "0-unstable-2025-06-23";

  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "TeleMikiya";
    rev = "69f33e97b37e436592cdbce96164ff6eb6827d75";
    hash = "sha256-xi8KBsx8DFaJDc8UdKDIv8vBkVoX0BzGNOAb7m8onuw=";
  };

  vendorHash = "sha256-pMhdFs8KVqULfG3Ry8v1/o1tgflpxcw2ntJXE92ep/s=";

  subPackages = [ "." ];
  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    mainProgram = "telemikiya";
    description = "Hybrid message search tool for Telegram";
    homepage = "https://github.com/XYenon/TeleMikiya";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xyenon ];
    broken = versionOlder go.version "1.24.0";
  };
}
