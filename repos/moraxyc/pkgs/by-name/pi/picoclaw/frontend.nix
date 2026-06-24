{
  lib,
  buildNpmPackage,
  picoclaw,

  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
}:
let
  pnpm = pnpm_10;
in
buildNpmPackage (finalAttrs: {
  pname = "picoclaw-launcher-frontend";
  inherit (picoclaw) src version;

  sourceRoot = "${finalAttrs.src.name}/web/frontend";

  nativeBuildInputs = [
    nodejs
    pnpm
  ];

  npmDeps = null;
  npmConfigHook = pnpmConfigHook;

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  meta = lib.removeAttrs picoclaw.meta [ "mainProgram" ];
})
