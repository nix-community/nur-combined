{ lib, stdenv, fetchFromGitHub, bashInteractive, installShellFiles }:

stdenv.mkDerivation (finalAttrs: {
  pname = "bash-completor";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "adoyle-h";
    repo = "bash-completor";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Ph+cQaXbykn703cdgkqlXcYMO4vvH6e0hCeecWS/6yA=";
  };

  nativeBuildInputs = [ bashInteractive installShellFiles ];

  buildFlags = [ "build" ];

  installPhase = ''
    install -Dm755 dist/bash-completor -t $out/bin
    installShellCompletion dist/bash-completor.completion.bash
  '';

  meta = with lib; {
    description = "Creating a bash completion script in a declarative way";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
