{ stdenv, fetchFromGitHub, lib, flex, yacc, openssl }:

stdenv.mkDerivation rec {
  name = "dma-${version}";
  version = "0.13";

  src = fetchFromGitHub {
    owner = "corecode";
    repo = "dma";
    rev = "v${version}";
    sha256 = "01yv1bkyim8f2jbdl83p5arrh53lyjq7dlmfl72ni4amafwfssx7";
  };

  buildInputs = [ openssl ];
  nativeBuildInputs = [ yacc flex ];

  postPatch = ''
    sed -i 's/-m [[:digit:]]\{3,4\} -o root -g mail//' Makefile
  '';
  makeFlags = [ "PREFIX=$(out)" "LEX=flex" ];

  meta = with lib; {
    description = "Small mail transport agent (MTA) designed for home and office use";
    homepage = "https://github.com/corecode/dma";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = [ maintainers.AluisioASG ];
  };
}
