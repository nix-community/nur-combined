{ lib, buildGo124Module, fetchFromGitHub }:
let
  commit = "2c07fc426fd000d2ea3963dec1b3c5efd9b1f4e7";
  version = "v0.0.5";
in
buildGo124Module {
  pname = "gwq";
  version = version;

  src = fetchFromGitHub {
    owner = "d-kuro";
    repo = "gwq";
    rev = commit;
    hash = "sha256-oSgDH5E3ETSlpovhU+MNmDTpY2BRGsR9Bf57ot04Rng=";
  };

  vendorHash = "sha256-jP4arRoTDcjRXZvLx7R/1pp5gRMpfZa7AAJDV+WLGhY=";

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/d-kuro/gwq/internal/cmd.version=${version}"
    "-X=github.com/d-kuro/gwq/internal/cmd.commit=${builtins.substring 0 7 commit}"
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
