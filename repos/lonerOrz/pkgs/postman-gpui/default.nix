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
  version = "0.1.3-unstable-2026-11-10";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "955249fb6e07249de232b4137589c654c257ae1b";
    hash = "sha256-P7ViTdKUoROKLkhmPdh55+rTtC7QBnPVTuOZyDawxhk=";
  };

  cargoHash = "sha256-Ly3f4GJwYYmckJgsn/AqzTunqtdFQ5dMCy9Q7i4Vonc=";

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
