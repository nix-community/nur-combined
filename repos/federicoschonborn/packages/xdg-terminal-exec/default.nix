{ lib
, stdenvNoCC
, fetchFromGitHub
, unstableGitUpdater
}:

stdenvNoCC.mkDerivation {
  pname = "xdg-terminal-exec";
  version = "unstable-2023-10-30";

  src = fetchFromGitHub {
    owner = "Vladimir-csp";
    repo = "xdg-terminal-exec";
    rev = "7b4ab959170476d33c46f1604aa07be355eac8e0";
    hash = "sha256-oNqx0MphXl2U3BHVEa/M/DWZvKV38gc3K98ds2RSBu4=";
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
