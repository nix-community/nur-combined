{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, libao
, libevdev
, libGL
, libX11 }:

stdenv.mkDerivation rec {
  name = "reicast-emulator";
  version = "r20.04";

  src = fetchFromGitHub {
    owner = "reicast";
    repo = name;
    rev = version;
    sha256 = "0vz3b1hg1qj6nycnqq5zcpzqpcbxw1c2ffamia5z3x7rapjx5d71";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libao
    libevdev
    libGL
    libX11
  ];

  cmakeFlags = [
    "-DOpenGL_GL_PREFERENCE=GLVND"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp reicast $out/bin/
  '';

  meta = with lib; {
    description = "reicast is a multi-platform Sega Dreamcast emulator.";
    homepage = "https://reicast.com/";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
