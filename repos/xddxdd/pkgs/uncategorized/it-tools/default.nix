{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
  nodejs_24,
  pnpm_11,
  fetchPnpmDeps,
  pnpmConfigHook,
  baseUrl ? "/",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "it-tools";
  version = "2026.7.11";
  src = fetchFromGitHub {
    owner = "sharevb";
    repo = "it-tools";
    tag = "v2026.7.11";
    hash = "sha256-Jo2S/LE8Hg4M/TdoivGq4CaSnHfbm70E1cFMdsFDjnE=";
  };
  pnpmDeps = fetchPnpmDeps {
    pname = "it-tools";
    version = "2026.7.11";
    src = fetchFromGitHub {
      owner = "sharevb";
      repo = "it-tools";
      tag = "v2026.7.11";
      hash = "sha256-Jo2S/LE8Hg4M/TdoivGq4CaSnHfbm70E1cFMdsFDjnE=";
    };
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

  passthru.updateScript = nix-update-script { };
  meta = {
    description = "Collection of handy online tools for developers, with great UX";
    homepage = "https://github.com/sharevb/it-tools";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = lib.platforms.unix;
  };
})
