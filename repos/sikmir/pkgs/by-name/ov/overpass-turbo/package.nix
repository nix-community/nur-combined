{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  cacert,
  nodejs,
  pnpm,
  pnpmConfigHook,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "overpass-turbo";
  version = "2026-07-18";

  src = fetchFromGitHub {
    owner = "tyrasd";
    repo = "overpass-turbo";
    rev = "6c9725ec93e4b1bd051b15b2199b281e2d1e4179";
    hash = "sha256-s/eXY2sCXlPf8EuKr3Bl0c9oFTzbSfmtHgPMLZDbvSE=";
  };

  postPatch = ''
    substituteInPlace vite.config.mts \
      --replace-fail "git log -1 --format=%cd --date=short" "echo ${finalAttrs.version}" \
      --replace-fail "git describe --always" "echo ${finalAttrs.src.rev}"
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-kAfuQAY0R4spfMSmEjh3/1RLEFQxxwwpDh4CQPb77w4=";
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

  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  meta = {
    description = "A web based data mining tool for OpenStreetMap using the Overpass API";
    homepage = "https://github.com/tyrasd/overpass-turbo";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
