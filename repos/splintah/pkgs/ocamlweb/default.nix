{ stdenv
, fetchurl
, ocaml
}:

stdenv.mkDerivation rec {
  name = "ocamlweb-${version}";
  version = "1.41";
  src = fetchurl {
    url = https://www.lri.fr/~filliatr/ftp/ocamlweb/ocamlweb-1.41.tar.gz;
    sha256 = "0gg9ian0jpfnlg1lb4srr4mwprc9pd5f8mipkqvgcrliifzj20jw";
  };
  buildInputs = [ ocaml ];
  buildPhase = ''
    ./configure
    make
  '';
  installPhase = ''
    make install prefix=$out
  '';
}
