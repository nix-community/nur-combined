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
  version = "0.1.0-rc.4-unstable-2026-10-15";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "6679080fc664fc68ea80f1876af8eb9fff7be4da";
    hash = "sha256-e970qs+M60u1htBgZX2xrvPDF9lsvY9SPsxqZWI4Y84=";
  };

  cargoHash = "sha256-h/AeKL1Rw9g8L+4tTsCNdMreLoBocHSASRQRhp7cPww=";

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
