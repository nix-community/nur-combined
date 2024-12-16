{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  vulkan-loader, vulkan-headers, shaderc, glslang
}:

stdenv.mkDerivation rec {
  pname = "stable-diffusion-cpp";
  version = "9578fdc";

  src = fetchFromGitHub {
    owner = "leejet";
    repo = "stable-diffusion.cpp";
    rev = "master-${version}";
    hash = "sha256-ZZ+pNdmXGKqdqayE3PUtT85cllKaGOaJzjxOEE4lEDY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake vulkan-headers shaderc glslang
  ];

  buildInputs = [
    vulkan-loader
  ];

  cmakeFlags = [
    "-DSD_VULKAN=ON"
  ];

  meta = {
    description = "Stable Diffusion and Flux in pure C/C";
    homepage = "https://github.com/leejet/stable-diffusion.cpp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "stable-diffusion-cpp";
    platforms = lib.platforms.all;
  };
}
