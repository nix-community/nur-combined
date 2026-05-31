{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  fetchpatch,
  nodejs,
  pnpm,
  pnpmConfigHook,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "overpass-turbo";
  version = "2026-02-22";

  src = fetchFromGitHub {
    owner = "tyrasd";
    repo = "overpass-turbo";
    rev = "55612905349b668f9f05e0272960c194dc289745";
    hash = "sha256-s3A33o0jV2edkav2VvkbjRqFJ/qpo+EAATPgc2ZR5JA=";
  };

  patches = [
    # https://github.com/tyrasd/overpass-turbo/pull/840
    (fetchpatch {
      url = "https://github.com/tyrasd/overpass-turbo/commit/867d1a61994379da7cf3f8821bbc84796d59e769.patch";
      hash = "sha256-HjFfToksyBMSIK+D1AezWMTLdlMvKlwNGN0P86LnTCk=";
    })
  ];

  postPatch = ''
    substituteInPlace vite.config.mts \
      --replace-fail "git log -1 --format=%cd --date=short" "echo ${finalAttrs.version}" \
      --replace-fail "git describe --always" "echo ${finalAttrs.src.rev}"
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-+o21KuMzbwCpZxXefSz6f+o71lHCMGIOc0ltOOihT/M=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    writableTmpDirAsHomeHook
  ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    mv dist $out
  '';

  meta = {
    description = "A web based data mining tool for OpenStreetMap using the Overpass API";
    homepage = "https://github.com/tyrasd/overpass-turbo";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
