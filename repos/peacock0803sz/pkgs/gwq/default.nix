{ lib, buildGo124Module, fetchFromGitHub }:
let
  version = "0.0.13";
in
buildGo124Module {
  pname = "gwq";
  inherit version;

  src = fetchFromGitHub {
    owner = "d-kuro";
    repo = "gwq";
    tag = "v${version}";
    hash = "sha256-10An8tKs7z2NNnI+KU+tjL7ZUS97m4gxglQ3Z5WiyeQ=";
  };

  vendorHash = "sha256-XoI6tu4Giy9IMDql4VmSP74FXaVD3nizOedmfPwIRCA=";

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
