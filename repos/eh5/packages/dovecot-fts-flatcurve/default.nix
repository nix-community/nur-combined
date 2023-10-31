{ stdenv
, lib
, fetchFromGitHub
, autoconf
, automake
, libtool
, pkg-config
, dovecot
, icu
, xapian
}:
stdenv.mkDerivation rec {
  pname = "dovecot-fts-flatcurve";
  version = "0.3.4";
  nativeBuildInputs = [ autoconf automake libtool ];
  buildInputs = [ dovecot icu xapian ];
  src = fetchFromGitHub {
    owner = "slusarz";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-R9qZ2EdcNS0/Maq6mPPX+BQCtMEM4qsMZA4nXmDlFA8=";
  };
  preConfigure = ''
    autoreconf -vi
  '';
  configureFlags = [
    "--with-dovecot=${dovecot}/lib/dovecot"
    "--with-moduledir=$(out)/lib/dovecot"
  ];
  meta = with lib; {
    homepage = "https://github.com/slusarz/dovecot-fts-flatcurve";
    description = "Dovecot FTS Flatcurve plugin (Xapian)";
    license = licenses.lgpl21Only;
    platforms = platforms.linux;
  };
}
