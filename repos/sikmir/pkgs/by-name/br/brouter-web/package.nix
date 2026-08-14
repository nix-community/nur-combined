{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nodejs,
  yarnConfigHook,
  yarnBuildHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "brouter-web";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "nrenner";
    repo = "brouter-web";
    tag = finalAttrs.version;
    hash = "sha256-tre+DVam2MoolUOWaBI7VOzUHR2VP3L7xO3/byg0B34=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-vVuzWu4GFSBaVBbj/qFPDUyFGObDFMhL2m2B4tiYvvg=";
  };

  nativeBuildInputs = [
    nodejs
    yarnConfigHook
    yarnBuildHook
  ];

  installPhase = ''
    install -dm755 $out
    cp -r index.html dist $out
  '';

  meta = {
    description = "Web client for BRouter, a routing engine based on OpenStreetMap";
    homepage = "https://github.com/nrenner/brouter-web";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
  };
})
