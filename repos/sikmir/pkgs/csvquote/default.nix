{ stdenv, csvquote }:

stdenv.mkDerivation rec {
  pname = "csvquote";
  version = stdenv.lib.substring 0 7 src.rev;
  src = csvquote;

  makeFlags = [ "BINDIR=$(out)/bin" ];

  preInstall = ''
    mkdir -p "$out/bin"
  '';

  meta = with stdenv.lib; {
    description = csvquote.description;
    homepage = csvquote.homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
