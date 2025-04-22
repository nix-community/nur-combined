{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "git-bug";
  # version 0.8.0 was 2022-11-20
  version = "0.8.0-unstable-2024-09-05";

  src = fetchFromGitHub {
    owner = "git-bug";
    repo = "git-bug";
    /*
    rev = "v${version}";
    sha256 = "12byf6nsamwz0ssigan1z299s01cyh8bhgj86bibl90agd4zs9n8";
    */
    rev = "b0cc690854e501af9d91e2f09366263d629ceeaa";
    hash = "sha256-VWopJ7FyJyN1PD5mN/1c7VZRcDhPn3rvpM9TS8+7zIw=";
  };

  vendorHash = "sha256-wux4yOc5OV0b7taVvUy/LIDqEgf5NoyfGV6DVOlczPU=";

  nativeBuildInputs = [ installShellFiles ];

  doCheck = false;

  excludedPackages = [ "doc" "misc" ];

  ldflags = [
    "-X github.com/MichaelMure/git-bug/commands.GitCommit=v${version}"
    "-X github.com/MichaelMure/git-bug/commands.GitLastTag=${version}"
    "-X github.com/MichaelMure/git-bug/commands.GitExactTag=${version}"
  ];

  postInstall = ''
    installShellCompletion \
      --bash misc/completion/bash/git-bug \
      --zsh misc/completion/zsh/git-bug \
      --fish misc/completion/fish/git-bug

    installManPage doc/man/*
  '';

  meta = with lib; {
    description = "Distributed bug tracker embedded in Git";
    homepage = "https://github.com/git-bug/git-bug";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ royneary DeeUnderscore sudoforge ];
    mainProgram = "git-bug";
  };
}
