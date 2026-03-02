{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
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

  postPatch = ''
    substituteInPlace vite.config.mts \
      --replace-fail "git log -1 --format=%cd --date=short" "echo ${finalAttrs.version}" \
      --replace-fail "git describe --always" "echo ${finalAttrs.src.rev}"
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-lyz1bcr7bnD5Wp9Srxn6dOH+gVdEQVF6xxuVE3Av3yc=";
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
