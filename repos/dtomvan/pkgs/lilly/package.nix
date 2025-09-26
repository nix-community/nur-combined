{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
  vlang,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lilly";
  version = "0-unstable-2025-08-21";

  src = fetchFromGitHub {
    owner = "tauraamui";
    repo = "lilly";
    rev = "1a8b8ea61ddfeb9cb02099ce10cc1fdf1029ff25";
    hash = "sha256-yo1BrrROIl6AIVDCeMQoM+bWLWleZWGJfqI1/ujQBV0=";
    leaveDotGit = true;
    postFetch = ''
      cd $out
      git describe --always --long > src/.githash
      rm -rf .git
    '';
  };

  nativeBuildInputs = [
    git
    vlang
  ];

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)
    v run make.vsh build-prod

    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck

    v run make.vsh verbose-test

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm555 lilly -t $out/bin

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "TUI editor and VIM/Neovim alternative";
    homepage = "https://github.com/tauraamui/lilly";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "lilly";
    platforms = lib.platforms.all;
  };
})
