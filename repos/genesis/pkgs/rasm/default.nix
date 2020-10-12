{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "rasm";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "EdouardBERGE";
    repo = "rasm";
    rev = "v${version}";
    sha256 = "1nfmr4s6pk0mpqzgii77pkck9ak09vd9y0vgkxlp64vwlwyb84hc";
  };

  buildPhase = ''
      # according to official documentation
      cc rasm.c -O2 -lm -lrt -march=native -o rasm
  '';

  installPhase = ''
    install -Dt $out/bin rasm
  '';

  meta = with stdenv.lib; {
    homepage = "http://www.roudoudou.com/rasm/";
    description = "Z80 assembler";
    # use -n option to display all licenses
    license = licenses.mit; # expat version
    maintainers = [ maintainers.genesis ];
    platforms = platforms.linux;
  };
}
