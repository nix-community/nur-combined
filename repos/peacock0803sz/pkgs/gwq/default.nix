{ lib, buildGo126Module, fetchFromGitHub }:
let
  version = "0.1.1";
in
buildGo126Module {
  pname = "gwq";
  inherit version;

  src = fetchFromGitHub {
    owner = "d-kuro";
    repo = "gwq";
    tag = "v${version}";
    hash = "sha256-MfCYFbODWnfPxx+6sLlcMT6tqghgILHB13+ccYqVjBA=";
  };

  vendorHash = "sha256-4K01Xf1EXl/NVX1loQ76l1bW8QglBAQdvlZSo7J4NPI=";

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
