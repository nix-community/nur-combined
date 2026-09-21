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
  version = "0-unstable-2026-09-18";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box-dashboard";
    rev = "9c498355c9973187b04c09991e2aca8100fd00ec";
    fetchSubmodules = true;
    hash = "sha256-s3gilFk10IPMyC945XwaLzu6M6S6xYU+ZbB8QQ7tggk=";
  };

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-MCld/J2LBtAz2bS00ICjCQN/QPXlLDKwzEGtFwlEl8c=";
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
