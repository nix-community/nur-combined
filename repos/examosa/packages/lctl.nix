{
  lib,
  fetchFromGitHub,
  installShellFiles,
  runCommand,
}: let
  pname = "lctl";
  version = "2026-06-21";
in
  runCommand "${pname}-${version}" {
    src = fetchFromGitHub {
      owner = "newtonne";
      repo = "lctl";
      rev = "58a5de5422a57c213876d7414f053ea283de1dde";
      hash = "sha256-4BQKf8GCrjjjMnGTnlEWphpCPWTy5HQfB4T38Fkjv6A=";
    };

    nativeBuildInputs = [installShellFiles];

    meta = {
      description = "User-friendly launchctl wrapper and helper functions";
      homepage = "https://github.com/newtonne/lctl";
      license = lib.licenses.mit;
      mainProgram = "lctl";
      platforms = lib.platforms.darwin;
    };
  } ''
    ln -sv $src/lctl.sh lctl
    installBin lctl

    installShellCompletion --cmd lctl \
      $src/completions/lctl.bash \
      --zsh $src/completions/_lctl
  ''
