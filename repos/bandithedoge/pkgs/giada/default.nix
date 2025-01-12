{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.giada) pname version src;

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
  ];

  buildInputs = with pkgs; [
    alsa-lib
    flac
    fmt
    fontconfig
    libGL
    libjack2
    libogg
    libopus
    libsamplerate
    libsndfile
    libvorbis
    nlohmann_json
    pulseaudio
    rtmidi
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXfixes
    xorg.libXft
    xorg.libXinerama
    xorg.libXpm
    xorg.libXrandr
  ];

  cmakeFlags = [
    "-DWITH_VST3=ON"
    "-DCMAKE_INSTALL_BINDIR=bin"
  ];

  meta = with pkgs.lib; {
    description = "An open source, minimalistic and hardcore music production tool. Designed for DJs, live performers and electronic musicians.";
    homepage = "https://www.giadamusic.com/";
    license = licenses.gpl3;
    platforms = ["x86_64-linux"];
  };
}
