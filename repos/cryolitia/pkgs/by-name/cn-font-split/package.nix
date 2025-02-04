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
    rev = "9f313ffbd20c6d4826f68b12b6cdd7a5cdaca919";
    hash = "sha256-Q560NXIwTGfAd2TKM3zaNQFdwAaA7HS/zv+FXaogWbw=";
  };

  doCheck = false;

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    cmake
    pkg-config
    protobuf
  ];

  cargoHash = "sha256-05DCmjYHNrtZkHcFvHLn5iaUz3x67+apgEye1CjXp3Q=";

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
