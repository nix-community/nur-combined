{
  stdenvNoCC,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_12,
  nodejs_26,

  source,
  meta,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "${source.pname}-frontend";
  inherit (source) version src;

  sourceRoot = "${finalAttrs.src.name}/frontend";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      ;
    pnpm = pnpm_12;
    fetcherVersion = 5;
    hash = source.pnpmDepsHash;
  };

  nativeBuildInputs = [
    nodejs_26
    pnpm_12
    pnpmConfigHook
  ];

  preBuild = ''
    chmod -R u+w ../backend/internal/web
  '';

  buildPhase = ''
    runHook preBuild

    pnpm run build:assets

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r ../backend/internal/web/dist $out

    runHook postInstall
  '';

  inherit meta;
})
