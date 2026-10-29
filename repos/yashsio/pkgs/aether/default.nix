{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  wayland,
  wayland-scanner,
  wayland-protocols,
  libxkbcommon,
  libffi,
}:

stdenv.mkDerivation {
  pname = "aether";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "yashsio";
    repo = "aether";
    rev = "c4993890b3433044e65c8689095b9cbe86a58848";
    hash = "sha256-zKwRZ9mm3Sleh7F1MnNJJyEhAwnmZn3I+tv7UALc434=";
  };

  cmakeFlags = [
    "-DWAYLAND_PROTOCOLS_DIR=${wayland-protocols}/share/wayland-protocols"
  ];

  nativeBuildInputs = [ cmake pkg-config wayland-scanner ];

  buildInputs = [ wayland wayland-protocols libxkbcommon libffi ];

  installPhase = ''
    install -Dm755 aether "$out/bin/aether"
  '';

  meta = {
    description = "A minimal wayland native image viewer";
    homepage = "https://github.com/yashsio/aether";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "aether";
  };
}
