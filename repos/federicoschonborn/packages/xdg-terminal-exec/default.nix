{ lib
, stdenvNoCC
, fetchFromGitHub
, unstableGitUpdater
}:

stdenvNoCC.mkDerivation {
  pname = "xdg-terminal-exec";
  version = "unstable-2023-11-26";

  src = fetchFromGitHub {
    owner = "Vladimir-csp";
    repo = "xdg-terminal-exec";
    rev = "2f48abc0764503b3024624c8703a5bf58d78bec2";
    hash = "sha256-3WsJPueFVUCO81GP9XHR9DtyIl4T0GC0HcAqZDsmhUc=";
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
