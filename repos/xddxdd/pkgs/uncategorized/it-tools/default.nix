{
  lib,
  sources,
  stdenv,
  nodejs_24,
  pnpm_11,
  fetchPnpmDeps,
  pnpmConfigHook,
  baseUrl ? "/",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = sources.it-tools.pname;
  inherit (sources.it-tools) version src;

  pnpmDeps = fetchPnpmDeps {
    inherit (sources.it-tools) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-5p/BNX+lEOAJlPlnKdjs1Zvk+Ty7hYeFU6pMzzShyog=";
  };

  nativeBuildInputs = [
    nodejs_24
    pnpm_11
    pnpmConfigHook
  ];

  env.BASE_URL = baseUrl;
  env.NODE_OPTIONS = "--max-old-space-size=8192";

  buildPhase = ''
    runHook preBuild
    pnpm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r dist/. $out/
    runHook postInstall
  '';

  meta = {
    description = "Collection of handy online tools for developers, with great UX";
    homepage = "https://github.com/sharevb/it-tools";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = lib.platforms.unix;
  };
})
