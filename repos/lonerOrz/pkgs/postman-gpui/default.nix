{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  libxcb,
  libxkbcommon,
  fontconfig,
  freetype,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "postman-gpui";
  version = "0.1.1-unstable-2026-10-20";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "c630ce92dd688e9677505cd17bbf1a464997551f";
    hash = "sha256-7NV7ucAcPqYuZ7LQoEVntc4R3gZNQ+gGmjmN/iX5DQs=";
  };

  cargoHash = "sha256-9OznCMlqCbeBvRKuSGsj1rmt1zTXDohEr75uNJA1/Cw=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libxcb
    libxkbcommon
    fontconfig
    freetype
    openssl
    wayland
  ];

  postFixup = ''
    patchelf \
      --add-rpath ${wayland}/lib \
      $out/bin/postman-gpui
  '';

  doCheck = false;

  passthru.updateArgs = [ "--version=branch" ];

  meta = {
    description = "Postman GPUI is a native, cross-platform HTTP client built with Rust and GPUI";
    homepage = "https://github.com/847850277/postman-gpui";
    license = lib.licenses.mit;
    mainProgram = "postman-gpui";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
