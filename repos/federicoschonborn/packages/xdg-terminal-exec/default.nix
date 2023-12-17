{ lib
, stdenvNoCC
, fetchFromGitHub
, unstableGitUpdater
}:

stdenvNoCC.mkDerivation {
  pname = "xdg-terminal-exec";
  version = "unstable-2023-12-16";

  src = fetchFromGitHub {
    owner = "Vladimir-csp";
    repo = "xdg-terminal-exec";
    rev = "5d8d0cd58020616af94d5352b365e3e4e5523abb";
    hash = "sha256-VrEOBC1FWt5JESftQ0S6Rij8JgE+FgbPLgi6uSyHdVw=";
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
