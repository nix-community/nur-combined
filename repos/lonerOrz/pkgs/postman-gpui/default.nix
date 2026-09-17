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
  version = "0.1.0-rc.2-unstable-2026-09-17";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "e040ed209ea860f74fd7855dadd98dd4e28f7113";
    hash = "sha256-RCf+EgYK1TcxHHGGVE+jUlNPxa5uAhuzOJaZuNWg7SA=";
  };

  cargoHash = "sha256-bDykPwgGEA0P0pMgzOsQwLqLpDhemiVF4IFN+Amap18=";

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
