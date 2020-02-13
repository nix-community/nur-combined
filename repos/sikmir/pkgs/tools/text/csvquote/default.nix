{ stdenv, sources }:

stdenv.mkDerivation rec {
  pname = "csvquote";
  version = stdenv.lib.substring 0 7 src.rev;
  src = sources.csvquote;

  makeFlags = [ "BINDIR=$(out)/bin" ];

  preInstall = ''
    mkdir -p "$out/bin"
  '';

  meta = with stdenv.lib; {
    inherit (src) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = with platforms; linux ++ darwin;
  };
}
