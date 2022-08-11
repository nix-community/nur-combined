{ lib, stdenv, fetchFromGitLab, physfs, openal, libvorbis, libogg, SDL2, ninja
, SDL2_sound, SDL2_ttf, freetype, SDL2_image, pixman, libpng, libjpeg, zlib
, libuchardet, meson, libiconv, xxd, pkg-config, libtheora, fluidsynth, ruby }:

stdenv.mkDerivation rec {
  pname = "mkxp-z";
  version = "2.4.0";

  src = fetchFromGitLab {
    owner = "mkxp-z";
    repo = pname;
    rev = "v2.4.0-fix";
    sha256 = "sha256-BBNnlCyfArYE/alyLyoSJBs0w1+T6RGeDtULcinfTTM=";
  };

  buildInputs = [
    physfs
    openal
    libvorbis
    libogg
    libtheora
    fluidsynth
    SDL2
    SDL2_sound
    SDL2_ttf
    freetype
    SDL2_image
    pixman
    libpng
    libjpeg
    zlib
    libuchardet
    libiconv
    ruby
  ];

  nativeBuildInputs = [ meson ninja pkg-config xxd ];

  postPatch = ''
    sed -i '25,26s/)/, required: false)/' src/meson.build
    patchShebangs linux/
  '';

  postInstall = ''
    # We don't need /lib and /lib64 as the executable contains all the dependencies.
    rm -rf $out/lib{,64}
  '';

  mesonFlags = [
    "-Dstatic_executable=false"
    "-Dworkdir_current=true"
    "-Dmri_version=${ruby.version.majMin}"
    "-Dcjk_fallback_font=true"
  ];

  # Fix include paths
  NIX_CFLAGS_COMPILE = "-I${openal}/include/AL -I${SDL2_sound}/include/SDL2";
  # Fix linked libraries
  NIX_LDFLAGS = "-ltheoradec";

  meta = with lib; {
    description = "RGSS on Steroids. With a ridiculous name.";
    homepage = "https://gitlab.com/mkxp-z/mkxp-z";
    license = licenses.gpl2;
  };
}
