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
  version = "0.1.0-rc.2-unstable-2026-09-20";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "b2b8bc48cb739b27716ce433e2ba808e05e3c346";
    hash = "sha256-tOU1d2bZTO8/+Bu0hD+Sqxjbd3MTx6FA+E7nIVeoC+8=";
  };

  cargoHash = "sha256-yN5MUlBTTHol1LFKCAwh6vuBCiVzk5b1CtZ8nrOZwzY=";

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
