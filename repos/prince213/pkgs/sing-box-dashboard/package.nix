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
  version = "0-unstable-2026-06-19";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box-dashboard";
    rev = "ff5d364b0f78899b4626b8597f1464f3cd6e0440";
    fetchSubmodules = true;
    hash = "sha256-Ud/tgY7MSAJ6iyIFtyzxiudsuOdeDcQviGA6XzXmJQ0=";
  };

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-YLMJc4TeuPq9YwKqTRP9FzSJpaqOrikfz7cP4U9yfIo=";
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
