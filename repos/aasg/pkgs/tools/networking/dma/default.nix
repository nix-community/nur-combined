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
    description = "Small mail transport agent designed for home and office use";
    longDescription = ''
      The DragonFly Mail Agent is a small Mail Transport Agent (MTA),
      designed for home and office use.  It accepts mails from locally
      installed Mail User Agents (MUA) and delivers the mails either
      locally or to a remote destination.  Remote delivery includes
      several features like TLS/SSL support and SMTP authentication.

      dma is not intended as a replacement for real, big MTAs like
      sendmail(8) or postfix(1).  Consequently, dma does not listen
      on port 25 for incoming connections.
    '';
    homepage = "https://github.com/corecode/dma";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ AluisioASG ];
  };
}
