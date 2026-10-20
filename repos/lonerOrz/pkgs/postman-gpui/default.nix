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
  version = "0.1.0-unstable-2026-10-19";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "b3b9923aca47ff254b749e2096a4473aa82211cf";
    hash = "sha256-Em89evcbDD+cxLbcww8l1/3p62a8MtLG0b92WUW15fs=";
  };

  cargoHash = "sha256-TNDQR9aW8ASx1YI1bp6Nl+0CrISvPaPMNLhMC2UVNA8=";

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
