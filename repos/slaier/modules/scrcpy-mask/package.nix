{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, pnpm_9
, nodejs_22
, cargo-tauri
, pkg-config
, wrapGAppsHook3
, openssl
, libsoup_3
, webkitgtk_4_1
,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scrcpy-mask";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "AkiChase";
    repo = "scrcpy-mask";
    rev = "30eafd7e1cc84c35fd98082154cdfc2de46ebbe2";
    hash = "sha256-+c682+ZD0zGzFkGqoDYqYm7jCjCNZRW6sufScH3MMOA=";
  };

  patches = [ ./longpress.patch ];

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-JlEFXmGzeRp8svwI5FzeKTrugefFQeqe2QRQ2F0ehc8=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      cargoRoot
      ;
    impureEnvVars = lib.fetchers.proxyImpureEnvVars;
    preBuild = ''
      if [ -n "''${cargoRoot-}" ]; then
        cd "$cargoRoot"
        unset cargoRoot
      fi
    '';
    hash = "sha256-u77V7GQRt65amfLoRFOf+ggWeSVo5KfX1hIhvrrcrvs=";
  };

  cargoRoot = "src-tauri";

  buildAndTestSubdir = finalAttrs.cargoRoot;

  nativeBuildInputs = [
    pnpm_9.configHook
    nodejs_22
    rustPlatform.cargoSetupHook
    cargo-tauri.hook
    rustPlatform.cargoCheckHook
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    libsoup_3
    webkitgtk_4_1
    openssl
  ];

  meta = {
    description = "A wrapper for scrcpy that adds overlay masks for mobile games";
    homepage = "https://github.com/AkiChase/scrcpy-mask";
    license = lib.licenses.asl20;
    mainProgram = "scrcpy-mask";
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
})
