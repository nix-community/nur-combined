{ lib, stdenv, fetchurl, cmake, unzip, ncurses5, SDL, SDL_mixer }:

stdenv.mkDerivation (finalAttrs: {
  pname = "ascii-dash";
  version = "1.3";

  src = fetchurl {
    url = "mirror://sourceforge/ascii-dash/ASCII-DASH-${finalAttrs.version}.zip";
    hash = "sha256-uXkSiEyW7R13mRqV9MyJ7XVsk60sVSZ93UQ/L5Z0uC0=";
  };

  postPatch = ''
    substituteInPlace ascii-gfx/main.cpp \
      --replace "boing.wav" "$out/share/ascii-dash/sounds/boing.wav"
    substituteInPlace dash/dash.cpp \
      --replace "sounds/" "$out/share/ascii-dash/sounds/"
    substituteInPlace dash/dash_physics.cpp \
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
    broken = stdenv.isDarwin; # mesa is broken
  };
})
