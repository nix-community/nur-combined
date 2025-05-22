{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  wrapQtAppsHook, qtbase, shaderc, makeDesktopItem, fetchpatch, git
}:

let
  sd = makeDesktopItem rec {
    name = "sd";
    exec = name;
    desktopName = "Stable Diffusion";
    categories = [ "Graphics" ];
  };
in stdenv.mkDerivation rec {
  pname = "stable-diffusion-cpp";
  version = "10c6501";

  src = fetchFromGitHub {
    owner = "piallai";
    repo = "stable-diffusion.cpp";
    rev = "CLI-GUI-${version}";
    hash = "sha256-lNO/8SLpH8sQe0yeZeEyJ6gc1WCEI0RxXVNW6LSHjqQ=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/leejet/stable-diffusion.cpp/pull/484.patch";
      hash = "sha256-VapHVytOgJEMKUG9EECZChpcD3CrauYcAnl21PNrxo4=";
    })
  ];

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook shaderc git
  ];

  buildInputs = [
    qtbase
  ];

  cmakeFlags = [
    "-DSD_EXAMPLES_GLOVE_GUI=ON"
    "-DSD_VULKAN=ON"
  ];

  postInstall = ''
    mkdir -p $out/share/applications
    ln -s ${sd}/share/applications/* $out/share/applications
  '';

  meta = {
    description = "Stable Diffusion in pure C/C++";
    homepage = "https://github.com/piallai/stable-diffusion.cpp";
    license = with lib.licenses; [ gpl3Only mit ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "sd";
    platforms = lib.platforms.all;
  };
}
