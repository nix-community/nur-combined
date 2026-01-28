{ lib, buildGo124Module, fetchFromGitHub }:
let
  version = "0.0.5";
in
buildGo124Module {
  pname = "gwq";
  inherit version;

  src = fetchFromGitHub {
    owner = "d-kuro";
    repo = "gwq";
    tag = "v${version}";
    hash = "sha256-oSgDH5E3ETSlpovhU+MNmDTpY2BRGsR9Bf57ot04Rng=";
  };

  vendorHash = "sha256-jP4arRoTDcjRXZvLx7R/1pp5gRMpfZa7AAJDV+WLGhY=";

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/d-kuro/gwq/internal/cmd.version=v${version}"
  ];
  doCheck = false;

  meta = {
    description = "🌳 Git worktree manager with fuzzy finder - Work on multiple branches simultaneously, perfect for parallel AI coding workflows";
    homepage = "https://github.com/d-kuro/gwq";
    license = lib.licenses.apsl20;
    platforms = lib.platforms.all;
    mainProgram = "gwq";
  };
}
