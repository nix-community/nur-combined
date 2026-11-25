{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  sqlite,
  libxcb,
  libxkbcommon,
  fontconfig,
  freetype,
  wayland,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "postman-gpui";
  version = "0.1.4-unstable-2026-11-24";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "5d400a7ea165af32707bfb7726245946c3600871";
    hash = "sha256-9uR465+9bwuDeoowiLjBkWInVIOEHHCbxqBadFhd8Sk=";
  };

  cargoHash = "sha256-IfKDHSdaJSaq5Y/+wkMMS4WRMldr4mTodFMHM++3/rg=";

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
    sqlite
    zlib
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
