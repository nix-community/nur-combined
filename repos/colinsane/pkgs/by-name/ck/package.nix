{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  onnxruntime,
}:

rustPlatform.buildRustPackage {
  pname = "ck";
  version = "0.7.11-unstable-2026-06-10";

  src = fetchFromGitHub {
    owner = "BeaconBay";
    repo = "ck";
    rev = "d2cfe11afebcdf5004314305f6c57eb38559344f";
    hash = "sha256-wDj+0GrmeBfdbSw7bcsgR6PoXC6l7XkltaIAxA64fGg=";
  };

  cargoHash = "sha256-N+fwBhW5e1zUaU2Pl0tzoXLzy5b1V2aHV2u1YQ80/pw=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
    onnxruntime
  ];

  env = {
    ORT_LIB_LOCATION = "${onnxruntime}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";
  };

  doCheck = false;

  meta = {
    description = "Semantic grep by embedding - find code by meaning, not just keywords";
    homepage = "https://github.com/BeaconBay/ck";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
    mainProgram = "ck";
  };
}
