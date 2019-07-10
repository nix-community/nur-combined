{ stdenv, fetchFromGitHub, neomutt, isync, msmtp, pass } :

stdenv.mkDerivation {
  name = "mutt-wizard";
  src = fetchFromGitHub {
    owner = "lukesmithxyz";
    repo = "mutt-wizard";
    rev = "ed2bb03f2dc313996ad8ceffc2feac80efde216f";
    sha256 = "0l2rhwyiww7fw4yc6k0bfc36rip23qkrlz76p4rq4xlcgwv1knby";
    };

  buildInputs = [ neomutt isync msmtp pass ];

  makeFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

  buildPhase =
  ''
  substituteInPlace Makefile --replace "/share/mutt-wizard" "/share/doc/mutt-wizard";
  substituteInPlace Makefile --replace "PREFIX =" "PREFIX ?=";
  '';

  meta = with stdenv.lib; {
    broken = true;
    homepage = "https://github.com/lukesmithxyz/mutt-wizard";
    description = "A system for automatically configuring mutt and isync with a simple interface and safe passwords";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };

}
