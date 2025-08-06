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
    owner = "wineee"; #"zccrs";
    repo = "git-commit-helper";
    rev = "2d2775b26e645c15aa540b8130c5c9256c7a7563";
    hash = "sha256-Bxx/N2F0T0qZmCRhWxPCVKohqSq6A24kXZnAvxi73Rw=";
  };

  cargoHash = "sha256-EkbjMT2Uy5/fG5gOWDncvU0Y4T8GcJTYTOV7FKpDT2c=";

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
