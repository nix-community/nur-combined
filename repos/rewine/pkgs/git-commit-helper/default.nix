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
  version = "0.5.0-unstable-2025-06-10";

  src = fetchFromGitHub {
    owner = "wineee"; # "zccrs";
    repo = "git-commit-helper";
    rev = "ba66e81cf87ff2ace70d9c44c50cbd001191bd18";
    hash = "sha256-BI9RIHNS1FVYJz2IuLFBP0QbCjoi3dcZvPRuyIWE2ho=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

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
