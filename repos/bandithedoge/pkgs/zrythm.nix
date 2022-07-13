{
  pkgs,
  sources,
}:
pkgs.stdenv.mkDerivation rec {
  inherit (sources.zrythm) pname version src;

  # nativeBuildInputs = with pkgs; [
  #   clang-tools
  #   help2man
  #   jq
  #   libxml2
  #   meson
  #   ninja
  #   pandoc
  #   pkg-config
  #   python39
  #   python39Packages.sphinx
  #   texi2html
  #
  #   cmake
  # ];
  #
  # buildInputs = with pkgs; [
  #   gettext
  #   guile
  #   flex
  #   xdg-utils
  #   graphviz
  #   glib
  #   lilv
  #   rubberband
  #   sass
  #   libjack2
  #   xorg.libX11
  # ];

  nativeBuildInputs = with pkgs; [
    help2man
    jq
    libaudec
    libxml2
    meson
    ninja
    pandoc
    pkg-config
    python3
    python3.pkgs.sphinx
    texi2html
    wrapGAppsHook
    cmake
  ];

  buildInputs = with pkgs; [
    (libadwaita.overrideAttrs (oldAttrs: {
      inherit (sources.libadwaita) pname version src;
    }))
    (stdenv.mkDerivation {
      pname = "libpanel";
      version = "1.0.alpha";
      src = pkgs.fetchgit {
        url = "https://gitlab.gnome.org/chergert/libpanel.git";
        rev = "11a83c39014254540015999a262f41a4e0fc7579";
        sha256 = "1fxhsk2c6cj0p409i2gfb7fi9fyz6hdaa2w7iy6sfsj7nwcfk333";
      };
      nativeBuildInputs = with pkgs; [
        pkg-config
        meson
        ninja
        cmake
      ];
      buildInputs = with pkgs; [
        libadwaita
        gobject-introspection
        glib
        gtk4
        vala
      ];
    })
    SDL2
    alsa-lib
    bash-completion
    boost
    breeze-icons
    carla
    chromaprint
    curl
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
    "-Dlsp_dsp=disabled"
    "-Dmanpage=true"
    "-Dopus=true"
    "-Dportaudio=enabled"
    "-Drtaudio=enabled"
    "-Drtmidi=enabled"
    "-Dsdl=enabled"
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

  inherit (pkgs.zrythm) meta;
}
