{ pkgs ? import <nixpkgs> {} }:

with pkgs;

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
    rev = "c69c75bf9beed9c7f7c8e9612e5e351855065120";
    sha256 = "148pk9iqpcgzwnxlcciqz0ngy6vsvxiv5lp17qg0bs7ph8ly3k4l";
  };

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
