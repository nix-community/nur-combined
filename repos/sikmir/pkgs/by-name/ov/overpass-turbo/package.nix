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
  version = "2026-07-19";

  src = fetchFromGitHub {
    owner = "tyrasd";
    repo = "overpass-turbo";
    rev = "bb21a1cad2bbb3bf02abeb380b565244feed2bf7";
    hash = "sha256-2KDOM2xtPg0257q2+PYI4ZC2YLnB0WyJ2SUWdk2y9ek=";
  };

  postPatch = ''
    substituteInPlace vite.config.mts \
      --replace-fail "git log -1 --format=%cd --date=short" "echo ${finalAttrs.version}" \
      --replace-fail "git describe --always" "echo ${finalAttrs.src.rev}"
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-NlZZvty3nfZcxb/Cw6X8IHIlJbqiSRrkDycgtQgvsIg=";
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
    broken = true; # Error: Cannot find module './vite-plus.linux-x64-gnu.node'
  };
})
