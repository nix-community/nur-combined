{ lib, rustPlatform, fetchFromGitHub, installShellFiles }:

rustPlatform.buildRustPackage rec {
  pname = "tempesta";
  version = "0.3.0"; # without "v"

  src = fetchFromGitHub {
    owner = "x71c9";
    repo = "tempesta";
    rev = "v${version}";
    hash = "sha256-MG/u/OGvgudQfLsiGbQ54UKy7bYa8FO17SN5UPgnYUQ=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [ installShellFiles ];

  doCheck = false;

  postInstall = ''
    installShellCompletion --cmd tempesta \
      --bash <($out/bin/tempesta completion bash) \
      --zsh <($out/bin/tempesta completion zsh) \
      --fish <($out/bin/tempesta completion fish)
    installShellCompletion --cmd t \
      --bash <($out/bin/tempesta completion bash) \
      --zsh <($out/bin/tempesta completion zsh) \
      --fish <($out/bin/tempesta completion fish)
    installShellCompletion --cmd tmps \
      --bash <($out/bin/tempesta completion bash) \
      --zsh <($out/bin/tempesta completion zsh) \
      --fish <($out/bin/tempesta completion fish)
    ln -s $out/bin/tempesta $out/bin/t
    ln -s $out/bin/tempesta $out/bin/tmps
  '';

  mainProgram = "tempesta";

  meta = with lib; {
    description = "The fastest and lightest bookmark manager CLI written in Rust";
    homepage = "https://github.com/x71c9/tempesta";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
