{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, ollama
, onnxruntime
}:

let
  pname = "patent";
  version = "0.14.3";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "r14dd";
    repo = "patent";
    rev = "v${version}";
    hash = "sha256-NB8fomYaSUOQrAECX/pY5iXEsUFlApbydZyeWqj3Vp4=";
  };

  cargoHash = "sha256-sOxWTQALQyTBwvx5yAPWUmd1BDsCMeZpFt2eyI0l4KM=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    onnxruntime
  ];

  env = {
    # Use the system-provided ONNX Runtime instead of letting ort-sys try to
    # download prebuilt binaries from the network during the sandboxed build.
    ORT_LIB_LOCATION = "${onnxruntime}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";
  };

  passthru = {
    inherit ollama;
  };

  # There are no tests
  doCheck = false;

  meta = {
    description = "A prior-art search for your code ideas. Stop building what already exists.";
    homepage = "https://github.com/r14dd/patent";
    license = with lib.licenses; [
      asl20
      mit
    ];
    mainProgram = "patent";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = lib.platforms.unix;
  };
}
