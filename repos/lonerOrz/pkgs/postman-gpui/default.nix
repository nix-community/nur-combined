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
  version = "0.1.3-unstable-2026-11-06";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "64f7a818a01c54faedfaa042d05fe49a9567c84c";
    hash = "sha256-Wf3czVfTea7+P0Iuhx5Ik38Uu7LyYLMZ27fYMbnXtSE=";
  };

  cargoHash = "sha256-bJhfhvvBSSydIkCJG67LnW3wbtirOLaUOLAaRPTGqdw=";

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
