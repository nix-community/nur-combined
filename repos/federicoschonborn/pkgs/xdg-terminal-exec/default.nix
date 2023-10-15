{ lib
, stdenvNoCC
, fetchFromGitHub
}:

stdenvNoCC.mkDerivation {
  pname = "xdg-terminal-exec";
  version = "unstable-2023-07-31";

  src = fetchFromGitHub {
    owner = "Vladimir-csp";
    repo = "xdg-terminal-exec";
    rev = "6426085370a3adafea933d53c123d813d7c7ab44";
    hash = "sha256-WEgmuEjcHrWUEHJn4Jl+g3GKajJWE2xWkBfI6MMsvXI=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm00755 $src/xdg-terminal-exec $out/bin/xdg-terminal-exec

    runHook postInstall
  '';

  meta = {
    description = "Proposal for XDG terminal execution utility";
    homepage = "https://github.com/Vladimir-csp/xdg-terminal-exec";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
