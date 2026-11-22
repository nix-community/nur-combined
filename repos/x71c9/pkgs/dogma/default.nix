{ lib, rustPlatform, fetchFromGitHub, installShellFiles, libgit2, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "dogma";
  version = "3.4.2"; # without "v"

  src = fetchFromGitHub {
    owner = "x71c9";
    repo = "dogma";
    rev = "v${version}";
    hash = "sha256-auRgNDE/YQdP2oKWSyG+cu7xsmkp49B6QZafrpUgz+U=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [ installShellFiles pkg-config ];
  buildInputs = [ libgit2 ];

  doCheck = false;

  postInstall = ''
    installShellCompletion --cmd dogma \
      --bash <($out/bin/dogma completions bash) \
      --zsh <($out/bin/dogma completions zsh) \
      --fish <($out/bin/dogma completions fish)
  '';

  mainProgram = "dogma";

  meta = with lib; {
    description = "Bridges secrets from vault backends and infrastructure outputs into sops-encrypted files deployed to NixOS machines";
    homepage = "https://github.com/x71c9/dogma";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
