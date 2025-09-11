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
  version = "0.7.0-unstable-2025-08-06";

  src = fetchFromGitHub {
    owner = "zccrs";
    repo = "git-commit-helper";
    rev = "f6b186f8f9d5abd73da78364dc028439d06c123c";
    hash = "sha256-elzU7qBjXUCxOFwWAG87Ajy/e18XP3cEZ0uDVeN8/V4=";
  };

  cargoHash = "sha256-EkbjMT2Uy5/fG5gOWDncvU0Y4T8GcJTYTOV7FKpDT2c=";

  doCheck = false;

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
    maintainers = with lib.maintainers; [ wineee ];
    mainProgram = "git-commit-helper";
  };
}
