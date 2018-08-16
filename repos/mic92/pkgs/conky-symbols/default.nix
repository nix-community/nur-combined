{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  name = "ConkySymbols";
  src = fetchzip {
    url = "https://github.com/Mic92/awesome-dotfiles/releases/download/download/ConkySymbols.ttf.tar.gz";
    sha256 = "08xhavw9kgi2jdmpzmxalcpbnzhng1g3z69v9s7yax4gj0jdlss5";
  };
  buildCommand = ''
    install -D $src/ConkySymbols.ttf "$out/share/fonts/truetype/ConkySymbols.ttf"
  '';

  meta = with stdenv.lib; {
    description = "iconic font for use in Conky";
  };
}
