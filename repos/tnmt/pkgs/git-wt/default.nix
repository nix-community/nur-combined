{ lib, buildGoModule, fetchFromGitHub, nix-update-script }:

buildGoModule rec {
  pname = "git-wt";
  version = "0.29.0";

  src = fetchFromGitHub {
    owner = "k1LoW";
    repo = "git-wt";
    rev = "v${version}";
    hash = "sha256-1u0GDC1Sc4Xy4URuM6TnR/ENsdIWa94Ixu3mL6WrmFg=";
  };

  vendorHash = "sha256-ppbY3ZJo2L/FbWlOiywqk6W4kVDQKkwf5VjRHucb78A=";

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Git subcommand for managing git worktrees";
    homepage = "https://github.com/k1LoW/git-wt";
    license = lib.licenses.mit;
    mainProgram = "git-wt";
  };
}
