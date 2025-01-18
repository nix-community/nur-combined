{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  pkg-config,
  protobuf,
}:
let

in
rustPlatform.buildRustPackage rec {
  pname = "cn-font-split";
  version = "7.2.1";

  src = fetchFromGitHub {
    owner = "KonghaYao";
    repo = "cn-font-split";
    rev = version;
    hash = "sha256-hQh3y6XKw7pSWOuMPqa/J0Au2K+pJjcPfxJtt7F5jZo=";
  };

  doCheck = false;

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    cmake
    pkg-config
    protobuf
  ];

  cargoHash = "sha256-Ewod+owzOV2Km4f/DpzeRdBDFWbq+V4mS7uk9R67pIE=";

  meta = {
    description = "A revolutionary font subetter that supports CJK and any characters!";
    longDescription = ''
      A revolutionary font subetter that supports CJK and any characters! It enables multi-threaded subset of otf, ttf, and woff2 fonts, allowing for precise control over package size.
    '';
    homepage = "https://github.com/KonghaYao/cn-font-split";
    maintainers = with lib.maintainers; [
      Cryolitia
    ];
    mainProgram = "cn-font-split";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
}
