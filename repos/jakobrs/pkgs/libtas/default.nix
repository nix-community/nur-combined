{ stdenv, multiStdenv, lib, fetchFromGitHub, fetchpatch,

  # nativeBuildInputs
  wrapQtAppsHook, # Because multiarch + qt5 is hard
  autoreconfHook, pkgconfig,
  git, # Used in configure to generate a version string or something like that

  # buildInputs
  xcbutilcursor, SDL2, alsaLib, ffmpeg,

  # Even more dependencies
  file, # Used to get information about the architecture of a file
  glibc, gcc-unwrapped, qtbase,
  libX11, libxcb, xcbutilkeysyms,
  fontconfig, freetype,
  libGL,

  # Multiarch is enabled whenever possible
  multiArch ? stdenv.hostPlatform.isx86_64, pkgsi686Linux
}:

let
  relevantStdenv = if multiArch then multiStdenv else stdenv;

in relevantStdenv.mkDerivation rec {
  pname = "libtas-unstable";
  version = "2020-12-24";

  src = fetchFromGitHub {
    owner = "clementgallet";
    repo = "libTAS";
    rev = "5d8f3fda5aaef804fe9a32f6695434b955684eab";
    hash = "sha256:0r3y071hsgfd24z2b26k8n8cpwrq39sswc00yjh3bv4a05kx7kb5";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig wrapQtAppsHook git ];
  buildInputs = [
    xcbutilcursor SDL2 alsaLib ffmpeg
  ] ++ lib.optionals multiArch [
    pkgsi686Linux.xorg.xcbutilcursor
    pkgsi686Linux.SDL2
    pkgsi686Linux.alsaLib
    pkgsi686Linux.ffmpeg
    # Why are these required here but not above?
    pkgsi686Linux.fontconfig
    pkgsi686Linux.freetype
  ];

  dontStrip = true; # Segfaults, bug in patchelf
  #dontPatchELF = true; # We'll do this ourselves

  patches = [
    ./libtaspath.patch
    (fetchpatch {
      url = "https://github.com/jakobrs/libTAS/commit/d5bcaca2e67691ec96e430228e6138e2a56f06c0.patch";
      sha256 = "1w93xp8l2m437a3s25qifhxfk9cqdamvpj5q99vawv2s3xw3zsjw";
    })
  ];

  # Note that this builds an extra .so file in the same derivation
  # Ideally the library and executable might be split into separate derivations,
  # but this is easier for now
  configureFlags = [
    "--enable-reproducible"
  ] ++ lib.optional multiArch "--with-i386";

  postPatch = ''
    substituteInPlace src/program/main.cpp \
      --subst-var out
  '';

  postInstall = ''
    mkdir -p $out/lib
    mv $out/bin/libtas*.so $out/lib/
  '';

  enableParallelBuilding = true;

  /*
  preFixup = ''
    for file in $out/{bin/libTAS,lib/libtas.so}; do
      patchelf \
        --set-rpath ${lib.makeLibraryPath [
          glibc gcc-unwrapped.lib qtbase
          libX11 libxcb xcbutilkeysyms xcbutilcursor
          ffmpeg alsaLib
          fontconfig.lib freetype
          libGL
        ]} \
        $file
    done
  '';
  */

  postFixup = ''
    wrapProgram $out/bin/libTAS --suffix PATH : ${lib.makeBinPath [ file ]}
  '';

  meta = {
    platforms = [ "x86_64-linux" "i686-linux" ];
    description = "GNU/Linux software to (hopefully) give TAS tools to native games";
    license = lib.licenses.gpl3Only;
  };
}
