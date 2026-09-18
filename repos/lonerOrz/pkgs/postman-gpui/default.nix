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
  version = "0.1.0-rc.2-unstable-2026-09-18";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "d7e01f9628b88cf509145a3cb5291d36e592d8b4";
    hash = "sha256-w1idvBVNmU3exqZatiIt/7pBU5LJCbMjMjXftay4iJU=";
  };

  cargoHash = "sha256-e1mLih7aUoxU5+eHO9VlukiFXvL9anVm9Vf3VGOxlMk=";

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
