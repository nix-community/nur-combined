{
  lib,
  fetchFromGitHub,
  installShellFiles,
  runCommand,
}: let
  pname = "lctl";
  version = "2026-06-28";
in
  runCommand "${pname}-${version}" {
    src = fetchFromGitHub {
      owner = "newtonne";
      repo = "lctl";
      rev = "a82c09a5868fa547cec6f5c199d838e8298e118f";
      hash = "sha256-2L4pBBYeJV2OhKaY2lRDEUpbZtql1M40Kn44neHCY6o=";
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

    installShellCompletion \
      $src/completions/lctl.{ba,fi}sh \
      --zsh $src/completions/_lctl
  ''
