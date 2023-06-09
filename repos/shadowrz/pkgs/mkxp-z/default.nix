{ lib, stdenv, fetchFromGitHub, physfs, openal, libvorbis, libogg, SDL2, ninja
, SDL2_sound, SDL2_ttf, freetype, SDL2_image, pixman, libpng, libjpeg, zlib
, libuchardet, meson, libiconv, xxd, pkg-config, libtheora, fluidsynth, ruby
, openssl }:

stdenv.mkDerivation (finalAttrs: {
  pname = "mkxp-z";
  version = "b594640ab7b781053bdbbcbeac357adae3b92b49";

  src = fetchFromGitHub {
    owner = "mkxp-z";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    sha256 = "sha256-IMDCyNex8lnHlsaupHiiubgLC+tklxMnDbhb50/gqDo=";
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
    openssl
  ];

  nativeBuildInputs = [ meson ninja pkg-config xxd ];

  postPatch = ''
    # Hardcode Git revision
    sed -i "/git_hash = /s:git_hash = .*:git_hash = '${finalAttrs.version}':" meson.build
    # Count for builtin iconv
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
})
