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
  version = "0.1.0-rc.3-unstable-2026-10-08";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "fbd1463e01fb185d7a107a2f645d22bdbe07f01c";
    hash = "sha256-FJT5MHHOXFO9zyEJ35cIGA2kxuQ9zyqoFT4mH+uGKHU=";
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
