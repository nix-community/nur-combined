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
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "zccrs";
    repo = "git-commit-helper";
    rev = "v${version}";
    hash = "sha256-UWvCv0Sb133rmA1vhMh4HiNx1z1z1wVOqi1qhP+cZ1g=";
  };

  cargoHash = "sha256-bsggIgWjdcRYzeZaYKRRf7MA8JYnsbhCbNcVRuDwNpc=";

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
