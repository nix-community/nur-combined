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
  version = "0.1.0-rc.1-unstable-2026-09-04";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "d650bc20c64f5bc7b681c6091b502c4431ea26e9";
    hash = "sha256-k/wa5u7F0WjpM/QfWeeju4hvN5XXcvJU61P3OdvJ3t4=";
  };

  cargoHash = "sha256-G2SZgImqwMNxCwU9I4FhEmfpU5bnZAxmHCRfoe1zIlk=";

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
