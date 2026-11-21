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
  pname = "${source.pname}-webui";
  inherit (source) version src;

  sourceRoot = "${finalAttrs.src.name}/webui";

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

  env.GIT_HASH = source.src.rev or source.version;

  buildPhase = ''
    runHook preBuild

    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  inherit meta;
})
