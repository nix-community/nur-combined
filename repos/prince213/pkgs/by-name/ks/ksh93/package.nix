{
  lib,
  buildPackages,
  fetchFromGitHub,
  fetchpatch2,
  stdenv,

  # passthru
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ksh93";
  version = "1.0.10-unstable-2026-10-29";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "ksh93";
    repo = "ksh";
    rev = "e73dadc97c88c4699e77dea09fc18bbd806461b4";
    hash = "sha256-B6ZdQqORVjfBoJsWeQ28Aee/DL/BWNgNRpJ2jEk1DJ0=";
  };

  patches = [
    # https://github.com/ksh93/ksh/pull/1067
    (fetchpatch2 {
      url = "https://github.com/ooonea/ksh/commit/33ac25287d4a0690b51ebe30002dd40ccd0bbee9.patch?full_index=1";
      hash = "sha256-q661ONgezpKx60f23maMoGhNUonKvj5PG19KToz3e2E=";
    })
  ];

  enableParallelBuilding = true;

  env = lib.optionalAttrs stdenv.buildPlatform.isLinux {
    STDCAT = lib.getExe' buildPackages.coreutils "cat";
    STDCHMOD = lib.getExe' buildPackages.coreutils "chmod";
    STDCP = lib.getExe' buildPackages.coreutils "cp";
  };

  buildPhase = ''
    runHook preBuild

    sh bin/package make ''${enableParallelBuilding:+-j$NIX_BUILD_CORES}

    runHook postBuild
  '';

  doCheck = !stdenv.buildPlatform.isLinux;

  # flaky
  preCheck = ''
    rm -f src/cmd/ksh93/tests/{basic,sigchld,signal}.sh
  '';

  checkPhase = ''
    runHook preCheck

    sh bin/package test

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    sh bin/package install $out

    runHook postInstall
  '';

  passthru = {
    shellPath = "/bin/ksh";
    updateScript = nix-update-script {
      extraArgs = [ "--version=branch=${finalAttrs.meta.branch}" ];
    };
  };

  meta = {
    description = "93u+m fork of the KornShell";
    branch = "1.0";
    homepage = "https://github.com/ksh93/ksh";
    downloadPage = "https://github.com/ksh93/ksh/releases";
    changelog = "https://github.com/ksh93/ksh/blob/${finalAttrs.meta.branch}/NEWS";
    license =
      with lib.licenses;
      AND [
        epl20
        epl10
        bsd3
      ];
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "ksh";
    platforms = lib.platforms.unix;
  };
})
