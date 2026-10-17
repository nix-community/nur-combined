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
  version = "0.1.0-rc.4-unstable-2026-10-16";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "9a6f40609ee63951fcec1d0505287e666f81490d";
    hash = "sha256-WCguoGFcy4yf/TBKE8E0Ohj+nqW0lmkOiQpVTkKXnqA=";
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
