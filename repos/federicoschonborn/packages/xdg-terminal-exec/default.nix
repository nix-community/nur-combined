{ lib
, stdenvNoCC
, fetchFromGitHub
, unstableGitUpdater
}:

stdenvNoCC.mkDerivation {
  pname = "xdg-terminal-exec";
  version = "unstable-2023-10-14";

  src = fetchFromGitHub {
    owner = "Vladimir-csp";
    repo = "xdg-terminal-exec";
    rev = "b6d2874f062f40c94cf665277ccdd62d7b8beff4";
    hash = "sha256-0bV7wfSDfh/o1HrivQYt1d4GwrVpS5oQX+ZJ7nkNCgs=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm00755 $src/xdg-terminal-exec $out/bin/xdg-terminal-exec

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    mainProgram = "xdg-terminal-exec";
    description = "Proposal for XDG terminal execution utility";
    homepage = "https://github.com/Vladimir-csp/xdg-terminal-exec";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
