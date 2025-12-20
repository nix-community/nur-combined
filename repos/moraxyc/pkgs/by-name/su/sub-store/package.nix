{
  lib,
  stdenv,
  fetchFromGitHub,

  pnpm_10,
  pnpm ? pnpm_10,
  makeBinaryWrapper,
  nix-update-script,

  nodejs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sub-store";
  version = "2.20.55";

  src = fetchFromGitHub {
    owner = "sub-store-org";
    repo = "Sub-Store";
    tag = finalAttrs.version;
    hash = "sha256-//CMHZ/ngASpSn502mrCVEIBmviGWAZSGDQ+pDD6nEw=";
  };

  sourceRoot = "${finalAttrs.src.name}/backend";

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
    pnpm
    makeBinaryWrapper
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      ;
    fetcherVersion = 2;
    hash = "sha256-cR0exF/yLNRsvK5+k2xVuSRBJlCiXCgrNyreTIkAQUw=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm bundle:esbuild

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r dist $out/share/sub-store
    makeWrapper ${lib.getExe nodejs} $out/bin/sub-store \
      --add-flags "$out/share/sub-store/sub-store.bundle.js"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Advanced Subscription Manager for QX, Loon, Surge, Stash, Egern and Shadowrocket";
    homepage = "https://github.com/sub-store-org/Sub-Store";
    changelog = "https://github.com/sub-store-org/Sub-Store/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "sub-store";
    platforms = nodejs.meta.platforms;
  };
})
