{
  pkgs,
  sources,
}: let
  zmusic = pkgs.stdenv.mkDerivation {
    inherit (sources.zmusic) src pname version;

    nativeBuildInputs = with pkgs; [
      cmake
      pkg-config
    ];

    buildInputs = with pkgs; [
      alsa-lib
      libsndfile
      mpg123
      zlib
      fluidsynth
    ];

    cmakeFlags = [
      "-DDYN_SNDFILE=OFF"
      "-DDYN_MPG123=OFF"
      "-DDYN_FLUIDSYNTH=OFF"
    ];

    preConfigure = ''
      sed -i \
        -e "s@/usr/share/sounds/sf2/@${pkgs.soundfont-fluid}/share/soundfonts/@g" \
        -e "s@FluidR3_GM.sf2@FluidR3_GM2-2.sf2@g" \
        source/mididevices/music_fluidsynth_mididevice.cpp
    '';
  };
in
  pkgs.stdenv.mkDerivation {
    inherit (sources.raze) src pname version;

    nativeBuildInputs = with pkgs; [
      cmake
      makeWrapper
      pkg-config
      copyDesktopItems
    ];

    buildInputs = with pkgs; [
      SDL2
      bzip2
      fluidsynth
      glib
      gtk3
      libGL
      libjpeg
      libsndfile
      libvpx
      openal
      pcre
      zlib
      zmusic
    ];

    cmakeFlags = [
      "-DDYN_GTK=OFF"
      "-DDYN_OPENAL=OFF"
    ];

    NIX_CFLAGS_LINK = "-lfluidsynth";

    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "raze";
        exec = "raze";
        desktopName = "Raze";
        categories = ["Game"];
      })
    ];

    installPhase = ''
      runHook preInstall

      install -Dm755 raze "$out/lib/raze/raze"

      for i in *.pk3; do
        install -Dm644 "$i" "$out/lib/raze/$i"
      done

      for i in soundfonts/*; do
        install -Dm644 "$i" "$out/lib/raze/$i"
      done

      mkdir $out/bin
      makeWrapper $out/lib/raze/raze $out/bin/raze

      runHook postInstall
    '';

    meta = {
      homepage = "https://github.com/ZDoom/Raze";
      description = "Build engine port backed by GZDoom tech. Currently supports Duke Nukem 3D, Blood, Shadow Warrior, Redneck Rampage and Powerslave/Exhumed.";
      license = pkgs.lib.licenses.gpl2;
      platforms = ["x86_64-linux"];
    };
  }
