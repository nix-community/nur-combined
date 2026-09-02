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
  version = "23.9.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "WordPress";
    repo = "gutenberg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Y/BhaA2zRYulEgg6PKBFOjW2nxOZJkFc40DS0LdJLWo=";
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
  npmDepsHash = "sha256-zV7BWGdh+BKWLKZAiJc2vcK+Nkva1k0+g+vbyuRIIts=";

  env.NO_CHECKS = "true"; # avoids git clean

  preBuild = ''
    patchelf \
      /build/source/node_modules/sass-embedded-*/dart-sass/src/dart \
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
