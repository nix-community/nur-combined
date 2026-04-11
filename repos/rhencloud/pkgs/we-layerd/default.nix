{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  ffmpeg,
  wayland,
  libX11,
  libXcomposite,
  libXfixes,
  libXdamage,
  libXrender,
  vulkan-loader,
}:

rustPlatform.buildRustPackage rec {
  pname = "we-layerd";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "Aromatic05";
    repo = "we-layerd";
    rev = "main";
    hash = "sha256-YyAaeHIYFVtjTpYFb3sTW/8ybIqJS28LHcqpDLI1bjg=";
  };

  cargoHash = "sha256-ik07WfbdMeTHGGGO2tvlERe5n2LSfLoDAjwyAC4QHNg=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    ffmpeg
    wayland
    libX11
    libXcomposite
    libXfixes
    libXdamage
    libXrender
    vulkan-loader
  ];

  meta = with lib; {
    description = "A Rust daemon for running Wallpaper Engine on Linux compositors";
    homepage = "https://github.com/Aromatic05/we-layerd";
    license = licenses.free;
    platforms = platforms.linux;
    mainProgram = "we-layerd";
  };
}
