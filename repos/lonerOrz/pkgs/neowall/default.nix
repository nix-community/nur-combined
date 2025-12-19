{
  stdenv,
  pkg-config,
  fetchFromGitHub,
  lib,
  libGL,
  libX11,
  libXrandr,
  libpng,
  libjpeg,
  wayland,
  wayland-scanner,
  wayland-protocols,
  meson,
  ninja,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "neowall";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "1ay1";
    repo = "neowall";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dgego9hcYCqnky7hvCubOZWHA1HxKDY9E9F/7YIwj+I=";
  };

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
    meson
    ninja
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libGL
    libpng
    libjpeg
    libX11
    libXrandr
  ];

  installFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    changelog = "https://github.com/1ay1/neowall/releases/tag/${finalAttrs.src.tag}";
    description = "GPU shader wallpapers for Wayland";
    homepage = "https://github.com/1ay1/neowall";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "neowall";
  };
})
