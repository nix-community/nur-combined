{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  onnxruntime,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ck-search";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "BeaconBay";
    repo = "ck";
    tag = finalAttrs.version;
    hash = "sha256-CZsayq1JxOhGaT9iTNVKcyqGGnJlxcjDAbcMKArtR6k=";
  };

  cargoHash = "sha256-+74XPcv/mnG7GAG6H8QJe6EtyO2xWhHXvdyTGSPwZeI=";

  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl onnxruntime];

  env.ORT_LIB_LOCATION = "${onnxruntime}/lib";

  doCheck = false;

  meta = {
    description = "Local first semantic and hybrid BM25 grep / search tool for use by AI and humans";
    homepage = "https://github.com/BeaconBay/ck";
    license = with lib.licenses; [asl20 mit];
    maintainers = [];
    mainProgram = "ck";
  };
})
