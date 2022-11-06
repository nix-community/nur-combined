{ lib, stdenv, fetchurl, cmake, unzip, ncurses5, SDL, SDL_mixer }:

stdenv.mkDerivation rec {
  pname = "ascii-dash";
  version = "1.2.1";

  src = fetchurl {
    url = "mirror://sourceforge/ascii-dash/ASCII-DASH-${version}.zip";
    hash = "sha256-MMkhsmWMtK606lWuuvtl2bq3ub9uWl24tqbCdnb8Da8=";
  };

  postPatch = ''
    substituteInPlace ascii-gfx/main.cpp \
      --replace "boing.wav" "$out/share/ascii-dash/sounds/boing.wav"
    substituteInPlace dash.cpp \
      --replace "sounds/" "$out/share/ascii-dash/sounds/"
    substituteInPlace dash_physics.cpp \
      --replace "sounds/" "$out/share/ascii-dash/sounds/"
    substituteInPlace main.cpp \
      --replace "data/" "$out/share/ascii-dash/data/"
  '';

  nativeBuildInputs = [ cmake unzip ];

  buildInputs = [ ncurses5 SDL SDL_mixer ];

  NIX_CFLAGS_COMPILE = [ "-Wno-error=mismatched-new-delete" ]
    ++ lib.optional stdenv.cc.isGNU "-Wno-error=stringop-truncation";

  installPhase = ''
    install -Dm755 main $out/bin/ascii-dash

    mkdir -p $out/share/ascii-dash
    cp -r ../{data,sounds} $out/share/ascii-dash
  '';

  meta = with lib; {
    description = "Remake of BOULDER DASH with NCurses";
    homepage = "https://ascii-dash.sourceforge.io/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
