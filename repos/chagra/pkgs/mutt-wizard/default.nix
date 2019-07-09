{ stdenv, fetchFromGitHub, neomutt, isync, msmtp, pass } :

stdenv.mkDerivation {
  name = "mutt-wizard";
  src = fetchFromGitHub {
    owner = "lukesmithxyz";
    repo = "mutt-wizard";
    rev = "8fb26e4cea8c1e03eb41e2b5ac8d901e32be7c17";
    sha256 = "1i5n57w90svf0s7lg2ljl9hv6vh92mbn73vvkzrphw5lax437c76";
    };


  buildInputs = [ neomutt isync msmtp pass ];

  makeFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

  buildPhase =
  ''
  substituteInPlace Makefile --replace "PREFIX =" "PREFIX ?=";
  '';

  meta = with stdenv.lib; {
    description = "A system for automatically configuring mutt and isync with a simple interface and safe passwords";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };

}
