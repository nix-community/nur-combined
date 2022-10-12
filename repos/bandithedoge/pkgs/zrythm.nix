{
  pkgs,
  sources,
}: let
  # remove when 2.6.0 gets added to nixpkgs
  carla = pkgs.stdenv.mkDerivation {
    inherit (sources.carla) pname version src;

    nativeBuildInputs = with pkgs; [
      pkg-config
    ];

    buildInputs = with pkgs; [
      file
      fluidsynth
      freetype
      gtk2
      gtk3
      liblo
      libsForQt5.qt5.qtbase
      xorg.libXcursor
      xorg.libXext
    ];

    enableParallelBuilding = true;

    dontWrapQtApps = true;

    installFlags = ["PREFIX=$(out)"];
  };
in
  pkgs.stdenv.mkDerivation rec {
    inherit (sources.zrythm) pname version src;
    nativeBuildInputs = with pkgs; [
      pkg-config
      help2man
      jq
      libaudec
      libxml2
      meson
      ninja
      pandoc
      python3
      python3.pkgs.sphinx
      texi2html
      wrapGAppsHook
    ];
    buildInputs = with pkgs; [
      SDL2
      alsa-lib
      bash-completion
      boost
      breeze-icons
      carla
      chromaprint
      curl
      dbus
      dconf
      fftw
      fftwFloat
      flex
      glib
      graphviz
      gtk4
      gtksourceview5
      guile
      json-glib
      libadwaita
      libbacktrace
      libcyaml
      libepoxy
      libgtop
      libjack2
      libpanel
      libpulseaudio
      libsForQt5.breeze-icons
      libsamplerate
      libsndfile
      libsoundio
      libyaml
      lilv
      lv2
      pcre
      pcre2
      reproc
      rtaudio
      rtmidi
      rubberband
      sassc
      serd
      sord
      sratom
      vamp-plugin-sdk
      xdg-utils
      xxHash
      zstd
    ];

    mesonFlags = [
      "-Db_lto=false"
      "-Ddebug=true"
      "-Dextra_extra_optimizations=true"
      "-Dextra_optimizations=true"
      "-Dlsp_dsp=disabled"
      "-Dmanpage=true"
      "-Dnative_build=true"
      "-Doptimization=3"
      "-Dopus=true"
      "-Dportaudio=enabled"
      "-Drtaudio=enabled"
      "-Drtmidi=enabled"
      "-Dsdl=enabled"
      "-Dfftw3_threads_separate=false"
    ];

    # for some reason meson can't find zix when it's build as a pkgconfig package and inserted into buildInputs
    # therefore we link its source to zrythm's source dir so it's treated as a kinda vendored dependency
    prePatch = ''
      ln -s ${sources.zix.src} subprojects/zix
    '';

    postPatch = ''
      chmod +x scripts/meson-post-install.sh
      patchShebangs ext/sh-manpage-completions/run.sh scripts/generic_guile_wrap.sh \
        scripts/meson-post-install.sh tools/check_have_unlimited_memlock.sh
    '';

    NIX_LDFLAGS = ''
      -lfftw3_threads -lfftw3f_threads
    '';

    preFixup = ''
      gappsWrapperArgs+=(
        --prefix GSETTINGS_SCHEMA_DIR : "$out/share/gsettings-schemas/${pname}-${version}/glib-2.0/schemas/"
               )
    '';

    dontStrip = true;

    inherit (pkgs.zrythm) meta;
  }
