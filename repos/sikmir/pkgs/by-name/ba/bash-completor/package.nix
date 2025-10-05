{
  lib,
  stdenv,
  fetchFromGitHub,
  bashInteractive,
  installShellFiles,
  bash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bash-completor";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "adoyle-h";
    repo = "bash-completor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nE+UPjDglFEPXyKZk1cs22eUaUxnWEjikMKcku4Pmy0=";
  };

  postPatch = ''
    substituteInPlace tools/build-dist --replace "/usr/bin/env bash" "${lib.getExe bash}"
  '';

  nativeBuildInputs = [
    bashInteractive
    installShellFiles
  ];

  buildFlags = [ "build" ];

  installPhase = ''
    install -Dm755 dist/bash-completor -t $out/bin
    installShellCompletion dist/bash-completor.completion.bash
  '';

  meta = {
    description = "Creating a bash completion script in a declarative way";
    homepage = "https://github.com/adoyle-h/bash-completor";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = stdenv.isLinux; # ./tools/build-dist: cannot execute: required file not found
  };
})
