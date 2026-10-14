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
  version = "0.1.0-rc.4-unstable-2026-10-14";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "1c1065355260160ecd6d0c2e6322b1040a4785d0";
    hash = "sha256-SfN0bJtii/6WK2c1Z2rKOaAAXYhs6XJ7LyDNUJLfWEw=";
  };

  cargoHash = "sha256-BJifSW5A8XBRi0m0ALqj+L45p0tXT64ax6RlegI9nmk=";

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
