{
  lib,
  fetchFromGitHub,
  installShellFiles,
  runCommand,
}: let
  pname = "lctl";
  version = "2025-02-19";
in
  runCommand "${pname}-${version}" {
    src = fetchFromGitHub {
      owner = "newtonne";
      repo = "lctl";
      rev = "1bea44ee82c553be4ccab858e4127ee283bf0e7d";
      hash = "sha256-7j6GyWc5k/WN+Q4TTcLAJs6Coynv5ACgMbabmBSc3ZA=";
    };

    nativeBuildInputs = [installShellFiles];

    meta = {
      description = "User-friendly launchctl wrapper and helper functions";
      homepage = "https://github.com/newtonne/lctl";
      license = lib.licenses.mit;
      mainProgram = "lctl";
      platforms = lib.platforms.all;
    };
  } ''
    mkdir -p $out/bin

    cp -v $src/lctl.sh lctl
    installBin lctl

    installShellCompletion --cmd lctl \
      --bash $src/completions/lctl.bash \
      --zsh $src/completions/_lctl
  ''
