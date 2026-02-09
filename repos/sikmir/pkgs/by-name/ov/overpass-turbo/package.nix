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
  version = "2026-01-28";

  src = fetchFromGitHub {
    owner = "tyrasd";
    repo = "overpass-turbo";
    rev = "644c5ec33864d3acadf25b5b7d3e6ad876d09c0d";
    hash = "sha256-HvCarTfqL33wYlrY6S+tqyc7d4fYqkYgw0P7X/bgTqQ=";
  };

  postPatch = ''
    substituteInPlace vite.config.mts \
      --replace-fail "git log -1 --format=%cd --date=short" "echo ${finalAttrs.version}" \
      --replace-fail "git describe --always" "echo ${finalAttrs.src.rev}"
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-S3MkYiQQUiztdFhfDkoPrI8c77VNx4AQVq0MPrCuqF4=";
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
