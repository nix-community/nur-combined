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
  version = "2026.9.27";
  src = fetchFromGitHub {
    owner = "sharevb";
    repo = "it-tools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tOTtibNYctIOX63MJzB28eq8FLmAuvtFuO/m226KUpE=";
  };
  pnpmDeps = fetchPnpmDeps {
    pname = "it-tools";
    inherit (finalAttrs) version;
    inherit (finalAttrs) src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-Qn2DCJpxtzJO1qRoPOkaUk6s1YcLzS/ll6jyNaDe/Xc=";
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

  passthru.updateScript = nix-update-script {
    # Skip dependency hashes: nix-update runs on GitHub Actions, whose
    # fetchPnpmDeps output is not reproducible (pnpm store race), so the
    # computed pnpmDeps hash does not match lantian's builders. Update only
    # version/src and refresh pnpmDeps manually when the lockfile changes.
    extraArgs = [ "--src-only" ];
  };
  meta = {
    description = "Collection of handy online tools for developers, with great UX";
    homepage = "https://github.com/sharevb/it-tools";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = lib.platforms.unix;
  };
})
