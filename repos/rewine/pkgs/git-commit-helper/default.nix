{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
  darwin,
  installShellFiles,
}:

rustPlatform.buildRustPackage rec {
  pname = "git-commit-helper";
  version = "0.5.0-unstable-2025-06-16";

  src = fetchFromGitHub {
    owner = "zccrs";
    repo = "git-commit-helper";
    rev = "de6297cd3669204cb5fa80f0f834147e03cf60bc";
    hash = "sha256-3nHPFejX6pdA8RBpBCZxq1pFDJrDvb7HKvVyPMboLpQ=";
  };

  cargoHash = "sha256-4FNWsPKGfeQAJ21aOtGcaEwarPLwv+0oEyTvcjIzHq8=";

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  postInstall = ''
    installShellCompletion --bash completions/git-commit-helper.bash
    installShellCompletion --fish completions/git-commit-helper.fish
    installShellCompletion --zsh completions/git-commit-helper.zsh
  '';

  meta = {
    description = "Ai git commit helper";
    homepage = "https://github.com/zccrs/git-commit-helper";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rewine ];
    mainProgram = "git-commit-helper";
  };
}
