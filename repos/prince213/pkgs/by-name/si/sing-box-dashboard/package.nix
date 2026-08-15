{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchPnpmDeps,

  # nativeBuildInputs
  pnpm_11,
  pnpmConfigHook,
}:
let
  pnpm = pnpm_11;
in
buildNpmPackage (finalAttrs: {
  pname = "sing-box-dashboard";
  version = "0-unstable-2026-08-15";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box-dashboard";
    rev = "96b91aab307d8fe016fc152d3fe3c8b6539e26c1";
    fetchSubmodules = true;
    hash = "sha256-dim7DcwKJhMm1nO7E4ovrNlhVzyPwS9Rgbss6QdMEKM=";
  };

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-QbcvSwJh5v+h4rYPAzGAViQX/LRQAlQdA+oXrp5zq0o=";
  };

  nativeBuildInputs = [ pnpm ];
  npmConfigHook = pnpmConfigHook;

  preBuild = ''
    npm run generate
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r dist/. $out

    runHook postInstall
  '';

  meta = {
    description = "Web dashboard for sing-box";
    homepage = "https://github.com/SagerNet/sing-box-dashboard";
    downloadPage = "https://github.com/SagerNet/sing-box-dashboard";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
