{ lib
, stdenv
, fetchFromGitHub
, alsa-lib
, bison
, bzip2
, flac
, fluidsynth
, freetype
, glib
, harfbuzz
, jack2
, lame
, lerc
, libdecor
, libGL
, libiconvReal
, libopus
, libpulseaudio
, libsndfile
, libtheora
, libtiff
, libuchardet
, mesa
, meson
, mpg123
, ninja
, openal
, openssl
, pcre2
, physfs
, pixman
, pkg-config
# , pkgsStatic
, ruby
, SDL2
, SDL2_image
, SDL2_sound
, SDL2_ttf
, unixtools
, wrapGAppsHook
, xorg
, zlib
}:

let
  ruby' = ruby.overrideAttrs (old: {
    configureFlags = [
      "--enable-install-static-library"
      "--enable-shared"
      "--disable-install-doc"
      "--with-out-ext=openssl,readline,dbm,gdbm"
      "--with-static-linked-ext"
      "--disable-rubygems"
      "--without-gmp"
    ];
  });
in

stdenv.mkDerivation rec {
  pname = "mkxp-z";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "mkxp-z";
    repo = "mkxp-z";
    rev = "v${version}";
    hash = "sha256-QjB+8qslC1g6gPt7qrHbufqJptNZrL9vY6KuTXOMRCk=";
  };

  nativeBuildInputs = [
    bison
    meson
    ninja
    pkg-config
    unixtools.xxd
    wrapGAppsHook
  ];

  buildInputs = [
    alsa-lib
    bzip2
    flac
    fluidsynth
    freetype
    glib
    harfbuzz
    jack2
    lame
    lerc
    libdecor
    libGL
    libiconvReal
    libopus
    libpulseaudio
    libsndfile
    libtheora
    libtiff
    libuchardet
    mesa
    mpg123
    openal
    openssl
    pcre2
    physfs
    pixman
    ruby'
    SDL2
    SDL2_image
    SDL2_sound
    SDL2_ttf
    xorg.libXcursor
    xorg.libXext
    xorg.libXi
    xorg.libXrandr
    xorg.libXScrnSaver
    zlib
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "global_link_args = []" "global_link_args = ['-ltheoradec']"

    substituteInPlace src/*.cpp src/*/*.cpp \
      --replace-quiet "#include <SDL_" "#include <SDL2/SDL_"
  '';

  # preConfigure = ''
  #   pushd linux
  #   make
  #   source vars.sh
  #   popd
  # '';

  mesonFlags = [
    "-Dcjk_fallback_font=true"
    "-Dworkdir_current=true"
  ];

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 mkxp-z.x86_64 $out/bin/mkxp-z
    # cp ../linux/mkxp-z.desktop $out/share/applications/
    # cp ../linux/mkxp-z.png $out/share/pixmap/
    # cp -r ../scripts $out/lib/mkxp-z/
  '';

  meta = with lib; {
    description = "Open-source cross-platform player for RPG Maker XP / VX / VX Ace games";
    homepage = "https://github.com/mkxp-z/mkxp-z";
    license = licenses.gpl2Plus;
    mainProgram = "mkxp-z";
    platforms = [ "x86_64-linux" ];
  };
}
