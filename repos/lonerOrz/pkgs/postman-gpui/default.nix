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
  version = "0.1.2-unstable-2026-10-30";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "5da6945f799bc926d1d7476eee314cdde0c38a54";
    hash = "sha256-uKK14kk3deoVGAMTNlSjYZQJhIgpUx+HtmkGcWK4dqI=";
  };

  cargoHash = "sha256-u55PJnrwttMqJYPykp53mMMAtHydaUtHYhVTPnwlnk0=";

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
