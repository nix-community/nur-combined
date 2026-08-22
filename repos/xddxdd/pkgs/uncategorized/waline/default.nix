{
  sources,
  lib,
  buildNpmPackage,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  inherit (sources.waline) pname version src;

  sourceRoot = "package";

  npmDepsHash = "sha256-XZIi/cNdWjcmM4G1j19bPSbbhnL31wQa2SNr56ZBh2E=";

  patches = [ ./runtime-path.patch ];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/waline \
      --add-flags "$out/lib/node_modules/@waline/vercel/vanilla.js"
  '';

  meta = {
    description = "Server for the Waline comment system";
    homepage = "https://github.com/walinejs/waline";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "waline";
    platforms = lib.platforms.linux;
  };
})
