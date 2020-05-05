{ pkgsi686Linux }:

with pkgsi686Linux;

let
  baserom = fetchurl {
    url = "http://127.0.0.1/baserom.us.z64";
    sha256 = "148xna5lq2s93zm0mi2pmb98qb5n9ad6sv9dky63y4y68drhgkhp";
  };
in stdenv.mkDerivation rec {
  pname = "sm64pc";
  version = "latest";

  buildInputs = [
    gnumake
    python3
    audiofile
    pkg-config
    SDL2
    libusb1
    glfw3
    libgcc
    xorg.libX11
    xorg.libXrandr
    libpulseaudio
    alsaLib
    glfw
    libGL
    unixtools.hexdump
  ];

  src = fetchgit {
    url = "https://tulpa.dev/saved/sm64pc";
    rev = "3439b5064b72cf89a6ea7f1ddd5992c34b3a321a";
    sha256 = "16csyfynyw09a4fizwka2iardkj7dnkpf12pvk8y22zcr5paak78";
  };

  patches = [ ./makefile_hack.patch ];

  buildPhase = ''
    chmod +x ./extract_assets.py
    cp ${baserom} ./baserom.us.z64
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./build/us_pc/sm64.us.f3dex2e $out/bin/sm64pc
  '';

  meta = with stdenv.lib; {
    description = "Super Mario 64 PC port, requires rom :)";
    license = licenses.unfree;
  };
}
