{
  sources,
  lib,
  buildNpmPackage,
  nodejs_26,
}:
buildNpmPackage (finalAttrs: {
  pname = "${sources.cleanuparr.pname}-frontend";
  inherit (sources.cleanuparr) version src;
  sourceRoot = "source/code/frontend";

  nodejs = nodejs_26;
  npmDepsHash = "sha256-HVA869ahw3PS9/a9JLhHS8KieioHAdRYjp2U47WcmVU=";

  npmBuildScript = "build";

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
