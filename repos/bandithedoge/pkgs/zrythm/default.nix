{
  pkgs,
  sources,
  ...
}: let
  # remove when 2.6.0 gets added to nixpkgs
  carla = pkgs.carla.overrideAttrs (_: {
    inherit (sources.carla-git) version src;
  });

  # remove when 4.14 gets added to nixpkgs
  gtk4 =
    (pkgs.gtk4.override {
      vulkanSupport = true;
    })
    .overrideAttrs (old: {
      inherit (sources.gtk-4_14_0) version src;
      buildInputs = old.buildInputs ++ (with pkgs; [libdrm]);

      postPatch = ''
        substituteInPlace meson.build \
          --replace 'if not meson.is_cross_build()' 'if ${pkgs.lib.boolToString (pkgs.stdenv.hostPlatform.emulatorAvailable pkgs.buildPackages)}'

        files=(
          build-aux/meson/gen-profile-conf.py
          build-aux/meson/gen-visibility-macros.py
          demos/gtk-demo/geninclude.py
          gdk/broadway/gen-c-array.py
          gdk/gen-gdk-gresources-xml.py
          gtk/gen-gtk-gresources-xml.py
          gtk/gentypefuncs.py
        )

        chmod +x ''${files[@]}
        patchShebangs ''${files[@]}
      '';
    });

  # remove when 6.0.1 gets added to nixpkgs
  rtaudio = pkgs.rtaudio.overrideAttrs (_: {
    inherit (sources.rtaudio-git) version src;
  });

  # remove when 1.5 gets added to nixpkgs
  libadwaita =
    (pkgs.libadwaita.override {
      inherit gtk4;
    })
    .overrideAttrs (_: {
      inherit (sources.libadwaita-1_5) version src;
    });
in
  pkgs.stdenv.mkDerivation rec {
    inherit (sources.zrythm) pname src;
    version = sources.zrythm.date;

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
      soxr
      sratom
      vamp-plugin-sdk
      xdg-utils
      xxHash
      yyjson
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
      license = licenses.agpl3Plus;
      platforms = platforms.linux;
    };
  }
