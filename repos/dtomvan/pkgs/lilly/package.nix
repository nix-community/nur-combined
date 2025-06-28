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
  version = "0-unstable-2025-06-28";

  src = fetchFromGitHub {
    owner = "tauraamui";
    repo = "lilly";
    rev = "7311543418e174d6de0c6be17c3fe9c24d3ead46";
    hash = "sha256-WxUIJUWWiGBcG2K8RwmkQyVrMHseY9wUHmaQ9Yzzddg=";
    leaveDotGit = true;
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
