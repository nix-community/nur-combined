{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "yggmail";
  version = "0-unstable-2026-07-24";

  src = fetchFromGitHub {
    owner = "neilalexander";
    repo = "yggmail";
    rev = "727c60d038f12ee00b746cb356f199d09f340a6e";
    hash = "sha256-vXKQ3bJm04IDMuUnnZhRa+v+qZaSQth9BQ4fn12zVW0=";
  };

  vendorHash = "sha256-Edf8Ugxi7IFWd8QARzomQy/jcL4wC3yYj2rOxek+6ms=";

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
