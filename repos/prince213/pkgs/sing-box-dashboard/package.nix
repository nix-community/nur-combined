{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpm_10,
  pnpmConfigHook,
}:
let
  pnpm = pnpm_10;
in
buildNpmPackage (finalAttrs: {
  pname = "sing-box-dashboard";
  version = "0-unstable-2026-06-12";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box-dashboard";
    rev = "16b397030584472e5edee3f2cff7278b0b00eca8";
    fetchSubmodules = true;
    hash = "sha256-UrZvtqc5i4ZRvwr2/7nF4yOmIV47V7tz9tPtOnSg9O4=";
  };

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-nBCgKNg/bVStjwFQclIChUxprUqDZBTXyxqiNqsdYOU=";
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
