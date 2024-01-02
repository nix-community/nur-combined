{ stdenv
, lib
, fetchFromGitHub
, autoreconfHook
, SDL
, SDL_image
, ftgl
, pkg-config
, libGLU
, freetype
, perl
, autoconf
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cmdlinegl";
  version = "unstable-2023-11-28";

  src = fetchFromGitHub {
    owner = "nrdvana";
    repo = "CmdlineGL";
    rev = "620469552046b6db6778d27c3bc19c389d5cb9e9";
    hash = "sha256-5hkZVLRFI5GXBRvVGyObxWforAaIjdpA0tb3syxl+8E=";
  };

  postPatch = ''
    export PROJROOT=$(pwd)
    cp -r script/* .
    sed -i 's;-$;- ${lib.concatStringsSep "-" (lib.tail (lib.splitString "-" finalAttrs.version))};'  Changes

    sed -i 's;.*FTGL/ftgl.h[^$]*;;' script/configure.ac # the headers would appear in the compiler calls 
    substituteInPlace script/config.h.in \
      --replace @ftgl_header@ FTGL/ftgl.h # for some reason configure is not detecting this  header

    substituteInPlace configure \
      --replace script/configure "script/configure --prefix=$out"

    substituteInPlace share/CmdlineGL.lib \
      --replace 'case "$0" in' "PATH=\"\$PATH:$out/bin\"; case \"\$0\" in"
  '';

  # configureFlags = [
  #   "--enable-dev"
  #   "--enable-debug"
  # ];

  configurePhase = "true";
  # doConfigure = false;


  nativeBuildInputs = [
    # autoreconfHook
    pkg-config
    perl
    autoconf
  ];

  buildInputs = [
    SDL
    SDL_image
    ftgl
    libGLU
    freetype
  ];
})
