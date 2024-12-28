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
  version = "7.0.0-beta-9";

  src = fetchFromGitHub {
    owner = "KonghaYao";
    repo = "cn-font-split";
    rev = version;
    hash = "sha256-3XOAnEmYmHTs/nNRv7YG8PGuAZ4hvcFOOWZCi02jo80=";
  };

  doCheck = false;

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    cmake
    pkg-config
    protobuf
  ];

  cargoHash = "sha256-n5xk9g4mFN1ujkJRtzEIem+XKfKT3E68OWMCeo+FKOs=";

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
