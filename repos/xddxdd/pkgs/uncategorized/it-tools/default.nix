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
  version = "2026.10.25";
  src = fetchFromGitHub {
    owner = "sharevb";
    repo = "it-tools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BzyA6559scTX6q+o1mACZ9WqdUpNHi0UEoDOlwMlYb0=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  pnpmDeps = fetchPnpmDeps {
    pname = "it-tools";
    inherit (finalAttrs) version;
    inherit (finalAttrs) src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-wLyMX6DtXXFvhyYY1ZuEFsTNsfZlRKXQZmy4etQRCdw=";
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
    # Skip dependency hashes: the fetcherVersion = 4 (pnpm 11) pnpmDeps hash
    # computed on GitHub Actions does not match lantian's builders. Switching
    # to pnpm_10 + fetcherVersion = 3 is not possible because this lockfile
    # stores pnpm 11 patch hashes in patchedDependencies, which pnpm 10
    # rejects. Update only version/src; refresh pnpmDeps manually.
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
