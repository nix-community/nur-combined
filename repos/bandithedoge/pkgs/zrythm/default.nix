{
  pkgs,
  sources,
  ...
}: let
  # remove when 2.6.0 gets added to nixpkgs
  carla =
    (pkgs.carla.overrideAttrs (_: {
      inherit (sources.carla-git) version src;
    }))
    .override {
      python3Packages = pkgs.python3Packages.override {
        overrides = final: prev: {
          # remove when https://nixpk.gs/pr-tracker.html?pr=370735 makes it to nixpkgs-unstable
          pyliblo = prev.pyliblo.overrideAttrs (_: {
            NIX_CFLAGS_COMPILE = ["-Wno-incompatible-pointer-types"];
          });
        };
      };
    };
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
      magic-enum
      pcre
      pcre2
      reproc
      rtaudio_6
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
