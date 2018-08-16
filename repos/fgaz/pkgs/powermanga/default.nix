{ stdenv, fetchFromGitHub, autoconf, automake, makeWrapper
, SDL, SDL_mixer, libpng }:

stdenv.mkDerivation rec {
  name = "powermanga-${version}";
  version = "0.93.1";
  src = fetchFromGitHub {
    owner = "brunonymous";
    repo = "Powermanga";
    rev = "${version}";
    sha256 = "0s1m86y2clfj5z3900fkcwrzn128p8vpp83xm8pq84xaknjd6nfh";
  };
  preConfigure = "./bootstrap";
  nativeBuildInputs = [ autoconf automake makeWrapper ];
  buildInputs = [ SDL SDL_mixer libpng ];
  installPhase = ''
    # We set the scoredir to $TMPDIR.
    # Otherwise it will try to write in /var/games at install time
    make install \
      gamesdir=$out/bin \
      scoredir=$TMPDIR
    # Sound is broken right now. SDL_mixer can't open the .zik (xm) files
    wrapProgram $out/bin/powermanga --add-flags --nosound
    rm -r $out/share/games/powermanga/sounds
  '';
}
