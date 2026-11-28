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
  libwebp,
}:

let
  version = "0.5.1";
in
stdenv.mkDerivation {
  pname = "aether";
  inherit version;

  src = fetchFromGitHub {
    owner = "yashsio";
    repo = "aether";
    tag = "v${version}";
    hash = "sha256-2na+yOAOj4doG/12auiEnbJw2df+B4fAkKFHzhUhpvE=";
  };

  cmakeFlags = [
    "-DWAYLAND_PROTOCOLS_DIR=${wayland-protocols}/share/wayland-protocols"
    "-DAETHER_WEBP_SYSTEM=ON"
  ];

  nativeBuildInputs = [ cmake pkg-config wayland-scanner ];

  buildInputs = [ wayland wayland-protocols libxkbcommon libffi libwebp ];

  installPhase = ''
    install -Dm755 aether "$out/bin/aether"
  '';

  meta = {
    description = "A minimal wayland native image viewer";
    homepage = "https://github.com/yashsio/aether";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "Aether";
  };
}
