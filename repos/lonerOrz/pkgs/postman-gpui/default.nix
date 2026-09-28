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
  version = "0.1.0-rc.2-unstable-2026-09-28";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "47df9552018e5c4114f57a738ad3d9ed1bafba07";
    hash = "sha256-UTm1llhtK045z3pb8fO7qy9hG6lIRnb7xECuw8h8NX0=";
  };

  cargoHash = "sha256-LR4leInqHaC7KqP6Qqw3LtvEznCNt7Oir1o2Sp2qUf4=";

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
