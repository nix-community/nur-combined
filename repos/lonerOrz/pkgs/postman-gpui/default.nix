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
  version = "0.1.0-rc.1-unstable-2026-09-16";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "09b498004801909655ce9d76c00f07bd3ae0c18a";
    hash = "sha256-upTh8fyITUPEn/LxS0R8hcq2mulgFxyoZ2ky3ckuECA=";
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
