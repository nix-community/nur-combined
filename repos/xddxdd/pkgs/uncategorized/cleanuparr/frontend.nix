{
  buildNpmPackage,
  dart-sass,
  lib,
  nodejs_26,
  src,
  version,
  npmDepsHash,
}:
buildNpmPackage (finalAttrs: {
  pname = "cleanuparr-frontend";
  inherit version src;
  __structuredAttrs = true;
  strictDeps = true;
  sourceRoot = "source/code/frontend";

  nodejs = nodejs_26;
  inherit npmDepsHash;

  npmBuildScript = "build";

  preBuild = ''
    substituteInPlace node_modules/sass-embedded/dist/lib/src/compiler-path.js \
      --replace-fail \
        'compilerCommand = (() => {' \
        'compilerCommand = (() => { return ["${lib.getExe dart-sass}"];'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/wwwroot
    cp -r dist/ui/browser/. $out/wwwroot/

    runHook postInstall
  '';

  meta = {
    description = "Angular web frontend for Cleanuparr (build artifact)";
    homepage = "https://github.com/Cleanuparr/Cleanuparr";
    license = lib.licenses.gpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
