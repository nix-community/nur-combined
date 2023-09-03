{
  pkgs,
  sources,
}: let
  # remove when 2.6.0 gets added to nixpkgs
  carla = pkgs.carla.overrideAttrs (_: {
    inherit (sources.carla-git) version src;
  });

  zix = pkgs.zix.overrideAttrs (_: {
    inherit (sources.zix-git) src version;
  });

  # remove when 4.13 gets added to nixpkgs
  gtk4 = pkgs.gtk4.overrideAttrs (oldAttrs: {
    inherit (sources.gtk-4_13_0) version src;

    postPatch =
      oldAttrs.postPatch
      + ''
        chmod +x build-aux/meson/gen-visibility-macros.py
        patchShebangs build-aux/meson/gen-visibility-macros.py
      '';
  });

  # remove when 1.4 gets added to nixpkgs
  libadwaita = pkgs.libadwaita.overrideAttrs (oldAttrs: {
    inherit (sources.libadwaita-1_4) version src;

    buildInputs = oldAttrs.buildInputs ++ [gtk4 pkgs.appstream];

    dontCheck = true;
  });
in
  pkgs.stdenv.mkDerivation rec {
    inherit (sources.zrythm) pname version src;

    nativeBuildInputs = with pkgs; [
      cmake
      faust2lv2
      help2man
      jq
      libaudec
      libsForQt5.wrapQtAppsHook
      libxml2
      meson
      ninja
      pandoc
      pkg-config
      python3
      python3.pkgs.sphinx
      sass
      sox
      texi2html
      wrapGAppsHook
    ];

    buildInputs = with pkgs; [
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
      libsamplerate
      libsForQt5.breeze-icons
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
      SDL2
      serd
      sord
      soxr
      sratom
      vamp-plugin-sdk
      xdg-utils
      xxHash
      zix
      zstd
    ];

    dontUseCmakeConfigure = true;

    mesonFlags = [
      "-Db_lto=false"
      "-Ddebug=true"
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

    meta = with pkgs.lib; {
      description = "A highly automated and intuitive digital audio workstation";
      homepage = "https://www.zrythm.org/";
      license = licenses.agpl3;
      platforms = platforms.linux;
    };
  }
