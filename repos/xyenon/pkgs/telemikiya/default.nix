{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  go,
}:

buildGoModule {
  pname = "telemikiya";
  version = "0-unstable-2025-03-29";

  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "TeleMikiya";
    rev = "4025e513b1a2a3173dcec01315043cd38c65a5d5";
    hash = "sha256-luDYfAEgGSpkDyJ4tO4OThL0ALIb3MnrzFW96mjGLcA=";
  };

  vendorHash = "sha256-wWS+I2JxXxCHKISe/aP8MJlHuwyVJshj6RLV6IN4j0Q=";

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
