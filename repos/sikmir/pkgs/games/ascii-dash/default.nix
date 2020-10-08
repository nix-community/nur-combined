{ stdenv, fetchurl, cmake, unzip, ncurses5, SDL, SDL_mixer }:

stdenv.mkDerivation rec {
  pname = "ascii-dash";
  version = "1.2.1";

  src = fetchurl {
    url = "mirror://sourceforge/ascii-dash/ASCII-DASH-${version}.zip";
    sha256 = "0mm04rz6a7kraprh7yjh5qmv9kd237lh85mknnm2nm6ff3mx6pf6";
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

  NIX_CFLAGS_COMPILE = [ "-Wno-error=stringop-truncation" ];

  installPhase = ''
    install -Dm755 main $out/bin/ascii-dash

    mkdir -p $out/share/ascii-dash
    cp -r ../{data,sounds} $out/share/ascii-dash
  '';

  meta = with stdenv.lib; {
    description = "Remake of BOULDER DASH with NCurses";
    homepage = "https://ascii-dash.sourceforge.io/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
