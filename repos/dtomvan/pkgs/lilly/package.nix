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
  version = "0-unstable-2025-06-20";

  src = fetchFromGitHub {
    owner = "tauraamui";
    repo = "lilly";
    rev = "bee9e0159e0342528bc8db737efbe1126b36e5d8";
    hash = "sha256-wPoNk7P6GFflGbWYRLvoz/Hagg6vozo0XDu0S4k3P0U=";
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
