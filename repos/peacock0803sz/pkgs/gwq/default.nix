{ lib, buildGo124Module, fetchFromGitHub }:
let
  version = "0.0.11";
in
buildGo124Module {
  pname = "gwq";
  inherit version;

  src = fetchFromGitHub {
    owner = "d-kuro";
    repo = "gwq";
    tag = "v${version}";
    hash = "sha256-T9G/sbI7P2I2yXNdX95SIr7Mzx87Z5oaqZmb6Y3Fooc=";
  };

  vendorHash = "sha256-c1vq9yETUYfY2BoXSEmRZj/Ceetu0NkIoVCM3wYy5iY=";

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
