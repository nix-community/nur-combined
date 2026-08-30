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
  version = "0.1.0-rc.1-unstable-2026-08-28";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "bd99e8d75058bef14639e1a449ad0f94679c5987";
    hash = "sha256-tH86TnIS/2gEgaNdllK4tHXRSkjneGzACtvzeDlPkps=";
  };

  cargoHash = "sha256-aQF9lJIOu+b5UOJAJxpXuGcXsODUrKWhkfVXLxymTNY=";

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
