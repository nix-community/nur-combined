{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, xorg
, libxkbcommon } :
stdenv.mkDerivation { 
  pname = "libuiohook";
  version = "unstable-2021-09-28";
  src = fetchFromGitHub {
    owner = "kwhat";
    repo = "libuiohook";
    rev = "e2c581f6d3012f68580e68a9e75b14e599baca88";
    sha256 = "sha256-a0ekq9udqmuaym9jfLFNNjBsX0rDZn/GKhJxOWC4sAw=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ 
    xorg.libX11
    xorg.libXtst
    xorg.libXt
    xorg.libXinerama
    xorg.libXi
    xorg.libxcb
    libxkbcommon
    xorg.libxkbfile
  ];

  meta = {
    description = "A multi-platform C library to provide global keyboard and mouse hooks from userland.";
    homepage = "https://github.com/kwhat/libuiohook";
    license = lib.licenses.lgpl3Plus;
  };

}