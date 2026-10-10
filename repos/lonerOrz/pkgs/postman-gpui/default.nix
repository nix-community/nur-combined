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
  version = "0.1.0-rc.3-unstable-2026-10-10";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "6c58786fb197b7c14bfa5dd4309ad15814d745a0";
    hash = "sha256-RXwxYR7rdQ/Sa4ts/sm/uadJJqSikoZo9cA0F3kY/VQ=";
  };

  cargoHash = "sha256-xsEHqCCeltF4ie/al+wtS+m2Dh3yNO8V+bn3kzeMwLs=";

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
