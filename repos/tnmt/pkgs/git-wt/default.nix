{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "git-wt";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "k1LoW";
    repo = "git-wt";
    rev = "v${version}";
    hash = "sha256-oGY9uMqP/hlIG9p/JaVqoBaxI7VFDIEIlwP5rBa3Diw=";
  };

  vendorHash = "sha256-4ak2Gx/i/yvj/tAoDJjsfpBUKJI5iDyKIuv7R7Pzz/w=";

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Git subcommand for managing git worktrees";
    homepage = "https://github.com/k1LoW/git-wt";
    license = lib.licenses.mit;
    mainProgram = "git-wt";
  };
}
