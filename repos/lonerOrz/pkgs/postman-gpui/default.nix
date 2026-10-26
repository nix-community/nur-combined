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
  version = "0.1.2-unstable-2026-10-26";

  src = fetchFromGitHub {
    owner = "847850277";
    repo = "postman-gpui";
    rev = "0d08efeba4bb8acf9af8489cf3b883d5e63a64a2";
    hash = "sha256-NlEX/fpUwKSIXF7MUIpZy5Q6NXgPwm8s/Ru5+GmKza4=";
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
