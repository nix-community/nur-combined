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
, libsysprof-capture
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
  rev = "711f9a455396152f5052a3bc5fe12bf113f997a2";
  short-rev = builtins.substring 0 7 rev;
in

stdenv.mkDerivation {
  pname = "mkxp-z";
  version = "2.4.2-unstable-2024-10-27";

  src = fetchFromGitHub {
    inherit rev;
    owner = "mkxp-z";
    repo = "mkxp-z";
    hash = "sha256-cj7b1LhK1uywj4e1oHh6pYgybkdE+zPwT+KrvthDck4=";
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
    libsysprof-capture
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
      --replace-fail "run_command('git', 'rev-parse', '--short', 'HEAD').stdout().strip()" "'${short-rev}'" \
      --replace-fail "global_link_args = []" "global_link_args = ['-ltheoradec']"

    substituteInPlace src/*.cpp src/*/*.cpp \
      --replace-quiet "#include <SDL_" "#include <SDL2/SDL_"
  '';

  mesonFlags = [
    "-Dcjk_fallback_font=true"
    "-Dmri_version=${ruby'.version.majMin}"
    "-Dworkdir_current=true"
  ];

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 mkxp-z.x86_64 $out/bin/mkxp-z
  '';

  meta = with lib; {
    description = "Open-source cross-platform player for RPG Maker XP / VX / VX Ace games";
    homepage = "https://github.com/mkxp-z/mkxp-z";
    license = licenses.gpl2Plus;
    mainProgram = "mkxp-z";
    platforms = [ "x86_64-linux" ];
  };
}
