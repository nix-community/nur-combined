{
  pkgs,
  sources,
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.cardinal) src pname version;

  nativeBuildInputs = with pkgs; [
    pkg-config
    copyDesktopItems
  ];

  buildInputs = with pkgs; [
    SDL2
    alsa-lib
    dbus
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

  postInstall = ''
    cp -r bin/Cardinal.clap $out/lib/clap
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

  makeFlags = ["SYSDEPS=true" "PREFIX=$(out)"];

  hardeningDisable = ["format"];

  meta = {
    inherit (pkgs.cardinal.meta) description homepage license platforms;
  };
}
