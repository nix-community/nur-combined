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
  version = "0.1.2-unstable-2026-10-29";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "4011d5043501092f4bf2e673d08959fc7f1bc77e";
    hash = "sha256-WnnoHCkMaUxBv4lLyG8N4ouDnmhn+s5XsT1/eDhvYQQ=";
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
