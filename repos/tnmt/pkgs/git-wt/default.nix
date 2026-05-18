{ lib, buildGoModule, fetchFromGitHub, nix-update-script }:

buildGoModule rec {
  pname = "git-wt";
  version = "0.28.0";

  src = fetchFromGitHub {
    owner = "k1LoW";
    repo = "git-wt";
    rev = "v${version}";
    hash = "sha256-JXPJlPAsbXXXN86ZB7PQNv31QZMiAn5DaYfHlnGWknc=";
  };

  vendorHash = "sha256-KYE9v+aSWprovDXXhWWmftLQCrH7QtjUYjnGK5m9s9Y=";

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
