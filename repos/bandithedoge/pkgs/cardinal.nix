{
  pkgs,
  sources,
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.cardinal) src pname;
  version = sources.cardinal.date;

  nativeBuildInputs = with pkgs; [
    cmake
    copyDesktopItems
    pkg-config
  ];

  dontUseCmakeConfigure = true;

  buildInputs = with pkgs; [
    SDL2
    alsa-lib
    dbus
    fftw
    freetype
    glib
    jansson
    libGL
    libarchive
    liblo
    libsamplerate
    mesa
    python3
    speexdsp
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXrandr
  ];

  prePatch = ''
    patchShebangs ./dpf/utils/generate-ttl.sh
  '';

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "cardinal";
      exec = "Cardinal";
      desktopName = "Cardinal";
      categories = ["AudioVideo" "Audio"];
    })
    (pkgs.makeDesktopItem {
      name = "cardinal-native";
      exec = "CardinalNative";
      desktopName = "Cardinal (Native)";
      categories = ["AudioVideo" "Audio"];
    })
  ];

  enableParallelBuilding = true;

  makeFlags = ["PREFIX=$(out)" "SYSDEPS=true" "STATIC_BUILD=true"];

  hardeningDisable = ["format"];

  meta = with pkgs.lib; {
    description = "Virtual modular synthesizer plugin";
    homepage = "https://github.com/DISTRHO/Cardinal";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
