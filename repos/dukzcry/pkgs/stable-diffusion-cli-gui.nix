{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  wrapQtAppsHook, qtbase, shaderc
}:

stdenv.mkDerivation rec {
  pname = "stable-diffusion-cpp";
  version = "9b5942";

  src = fetchFromGitHub {
    owner = "piallai";
    repo = "stable-diffusion.cpp";
    rev = "CLI-GUI-d${version}";
    hash = "sha256-kTD5hYgZaxMcfWOcv1FfhuOiWG/4SWnMbtBuUFX8ZVc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook shaderc
  ];

  buildInputs = [
    qtbase
  ];

  cmakeFlags = [
    "-DSD_EXAMPLES_GLOVE_GUI=ON"
    "-DSD_VULKAN=ON"
  ];

  meta = {
    description = "Stable Diffusion in pure C/C";
    homepage = "https://github.com/piallai/stable-diffusion.cpp";
    license = with lib.licenses; [ gpl3Only mit ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "stable-diffusion-cpp";
    platforms = lib.platforms.all;
  };
}
