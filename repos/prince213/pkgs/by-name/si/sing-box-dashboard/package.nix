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
  version = "0-unstable-2026-08-12";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box-dashboard";
    rev = "e5b293de743b2f4de1f3d3a14fc260ab42b93139";
    fetchSubmodules = true;
    hash = "sha256-GhYo0i4Lhv7e4iDbhklPPbLaPzOkfWz8ExKmA/LeLp4=";
  };

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-Pc5VcwlE/bAlTYvATfFKPM5k37AD0W1SJxtlbygt2RA=";
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
