{
  lib,
  stdenv,
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
  version = "0.1.2-unstable-2026-11-05";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "ad6f408564f6f0e3ac1914e66c8225d5d6e18b34";
    hash = "sha256-EVhWSEJj4pF9GlWNpiFQQ0AFE1tC3c3fqc5lG/cZIzI=";
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
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland
  ];

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
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
