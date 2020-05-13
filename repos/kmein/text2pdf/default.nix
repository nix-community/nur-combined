{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "text2pdf";
  version = "1.1";
  src = fetchurl {
    url = "http://www.eprg.org/pdfcorner/text2pdf/text2pdf.c";
    sha256 = "002nyky12vf1paj7az6j6ra7lljwkhqzz238v7fyp7sfgxw0f7d1";
  };
  phases = [ "buildPhase" ];
  buildPhase = ''
    mkdir -p $out/bin
    gcc -o $out/bin/text2pdf $src
  '';
}
