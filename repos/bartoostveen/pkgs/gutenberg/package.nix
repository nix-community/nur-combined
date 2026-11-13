{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
  zip,
  unzip,
}:

buildNpmPackage (finalAttrs: {
  pname = "gutenberg";
  version = "24.4.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "WordPress";
    repo = "gutenberg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Cj132oKchDPpIdtdjbs/cjeK3X8pDgELwdj128P4KDc=";
  };

  patches = [
    ./0001-chore-rtc-default-peer-limit-3-15.patch
    ./0002-fix-build-do-not-run-git-clean.patch
    ./0003-fix-build-do-not-run-commands-silently.patch
    ./0004-fix-build-do-not-run-npm-ci.patch
    ./0005-fix-build-reverse-useless-changes.patch
  ];

  nativeBuildInputs = [
    zip
  ];

  npmBuildScript = "build:plugin-zip";
  npmRebuildFlags = [ "--dangerously-allow-all-scripts" ];

  npmDepsHash = "sha256-jvPgxaNluaIRQ7tuOIbZchB8bdIh4rsfywgJ1xTX95I=";
  npmDepsFetcherVersion = 2;

  env.NO_CHECKS = "true"; # avoids git clean

  preBuild = ''
    patchelf \
      /build/source/node_modules/.store/sass-embedded-*/node_modules/sass-embedded-*/dart-sass/src/dart \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker)
  '';

  installPhase = ''
    runHook preBuild
    ${lib.getExe unzip} gutenberg.zip -d $out
    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The Block Editor project for WordPress and beyond.";
    homepage = "https://github.com/WordPress/gutenberg";
    changelog = "https://github.com/WordPress/gutenberg/blob/${finalAttrs.src.rev}/changelog.txt";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "gutenberg";
    platforms = lib.platforms.all;
  };
})
