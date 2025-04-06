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
  version = "7.5.5";

  src = fetchFromGitHub {
    owner = "KonghaYao";
    repo = "cn-font-split";
    rev = version;
    hash = "sha256-1IdmWJSAt2UJHCJA8BecXuBsYIiDcqy16N8tEcj7iTU=";
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    cmake
    pkg-config
    protobuf
  ];

  doCheck = false;

  cargoHash = "sha256-1YaryUJFwXx5XY5JYD7ixwHfAUUKnTQ7dzqcLbvRsBI=";

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
