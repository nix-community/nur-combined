# FIXME go.mod file not found
# FIXME 2to3: scripts/generate-supported requires python2

{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {

  pname = "wingo";
  version = "unstable-2020-10-11";

  src = fetchFromGitHub {
    owner = "BurntSushi";
    repo = "wingo";
    rev = "30b336cbb88d32c12c14768d5ff89b3d55560081";
    hash = "sha256-Jo22rg++LqjDUoNwV8lQj23V1XhasqlkxKlLG4/WBNY=";
  };

  vendorHash = "";

  ldflags = [
    "-s"
    "-w"
    "-X=main.name=wingo"
    "-X=main.version=${version}"
    "-X=main.commit=${src.rev}"
    "-X=main.date=1970-01-01T00:00:00Z"
  ];

  meta = with lib; {
    description = "A fully-featured window manager written in Go";
    homepage = "https://github.com/BurntSushi/wingo";
    license = licenses.wtfpl;
    maintainers = with maintainers; [ ];
    mainProgram = "wingo";
    platforms = platforms.all;
  };
}
