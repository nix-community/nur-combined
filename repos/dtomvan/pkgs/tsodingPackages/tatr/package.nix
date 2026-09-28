{
  lib,
  buildNobPackage,
  fetchFromGitHub,
  nix-update-script,
}:

buildNobPackage {
  pname = "tatr";
  version = "0-unstable-2026-09-14";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "tatr";
    rev = "9b0d752d992c024875882937eb1a0705ba4ba7fb";
    hash = "sha256-yJPfmc8Cv4wvFjJcowePrgzsXihM3FzSmY9nOId5Og4=";
  };

  patches = [
    # For reproducibility
    ./0001-fix-do-not-log-build-time.patch
  ];

  outPaths = [ "build/tatr" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=main" ];
  };

  meta = {
    description = "Task Tracker";
    homepage = "https://github.com/tsoding/tatr";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [
      bartoostveen
      dtomvan
    ];
    mainProgram = "tatr";
    platforms = lib.platforms.all;
  };
}
