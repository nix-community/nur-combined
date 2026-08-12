{
  fetchFromGitHub,
  fluidsynth,
  freetype,
  lib,
  libiconv,
  libjpeg,
  libogg,
  libpng,
  libtheora,
  libuchardet,
  libvorbis,
  libGL,
  makeWrapper,
  meson,
  ninja,
  openal,
  openssl,
  physfs,
  pixman,
  pkg-config,
  ruby,
  stdenv,
  xxd,
  zlib,
  SDL2,
  SDL2_image,
  SDL2_sound,
  SDL2_ttf,
}:

let
  # Use a Ruby with statically linked extensions
  rubyStaticExt =
    (ruby.override {
      docSupport = false;
    }).overrideAttrs
      (old: {
        configureFlags = old.configureFlags or [ ] ++ [
          "--with-static-linked-ext"
        ];
      });
in

stdenv.mkDerivation (finalAttrs: {
  pname = "mkxp-z";
  version = "0-unstable-2025-11-12";

  src = fetchFromGitHub {
    owner = "mkxp-z";
    repo = finalAttrs.pname;
    rev = "1eabaec21bb76dd4ec1f36229f7ea5a734a98eef";
    sha256 = "sha256-zANeU3dmumPtc1JUWlCOM9BmO/3Z1v+ihNshnYcC/6k=";
  };

  buildInputs = [
    fluidsynth
    freetype
    libiconv
    libjpeg
    libogg
    libpng
    libtheora
    libuchardet
    libvorbis
    libGL
    openal
    openssl
    physfs
    pixman
    rubyStaticExt
    zlib
    SDL2
    SDL2_image
    SDL2_sound
    SDL2_ttf
  ];

  nativeBuildInputs = [
    makeWrapper
    meson
    ninja
    pkg-config
    xxd
  ];

  postPatch = ''
    # Hardcode Git revision
    sed -i "/git_hash = /s:git_hash = .*:git_hash = '${finalAttrs.version}':" meson.build
    # Count for builtin iconv
    sed -i '37,38s/)/, required: false)/' src/meson.build
    patchShebangs linux/
  ''
  + lib.optionalString (lib.strings.versionAtLeast SDL2_ttf.version "2.24.0") ''
    substituteInPlace src/display/font.h --replace-fail '_TTF_Font' 'TTF_Font'
    substituteInPlace src/display/font.cpp --replace-fail '_TTF_Font' 'TTF_Font'
  '';

  postInstall = ''
    # We don't need /lib and /lib64 as the executable contains all the dependencies.
    rm -rf $out/lib{,64}
    # Don't attach arch to executable
    mv $out/bin/mkxp-z.* $out/bin/mkxp-z
  '';

  mesonFlags = [
    (lib.mesonBool "static_executable" stdenv.hostPlatform.isStatic)
    (lib.mesonBool "workdir_current" true)
    (lib.mesonBool "cjk_fallback_font" true)
    (lib.mesonOption "mri_version" ruby.version.majMin)
  ];

  env = {
    # Fix include paths
    NIX_CFLAGS_COMPILE = toString [
      "-I${lib.getDev openal}/include/AL"
      "-I${lib.getDev SDL2_sound}/include/SDL2"
      "-I${lib.getDev SDL2_ttf}/include/SDL2"
    ];
    # Fix linked libraries
    NIX_LDFLAGS = "-ltheoradec";
  };

  meta = with lib; {
    description = "RGSS on Steroids. With a ridiculous name.";
    homepage = "https://gitlab.com/mkxp-z/mkxp-z";
    license = licenses.gpl2;
  };
})
