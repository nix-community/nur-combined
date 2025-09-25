{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  pkg-config,
  ninja,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wooz";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "negrel";
    repo = "wooz";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-mOrxRjvvcPTauBwau5Za/e3kqyN5ZJtU9ZTqmDyj/YY=";
  };

  buildInputs = [
    meson
    pkg-config
    ninja
    wayland
    wayland-protocols
    wayland-scanner
  ];

  buildFlags = [ "CFLAGS=-O3" ];

  meta = {
    description = "Zoom / magnifier utility for wayland compositors";
    homepage = "https://github.com/negrel/wooz.git";
    mainProgram = "wooz";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
