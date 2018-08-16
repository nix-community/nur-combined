{ stdenv, fetchsvn, autoconf, libtool, automake, pkgconfig }:
stdenv.mkDerivation rec {
  name = "libthai-${version}";
  rev = "v${version}";
  version = "280";

  src = fetchsvn {
    url = "https://linux.thai.net/svn/software/datrie/trunk/";
    rev = version;
    sha256 = "0dq3kvi1xv166hrspl4wdhh6yqanh23zqbgrw08sgqa0yyrixgyi";
  };

  nativeBuildInputs = [ automake autoconf libtool pkgconfig ];

  preConfigure = ''
    #sed -i '/pattern to match/d' configure.ac
    substituteInPlace configure.ac --replace 'AX_COMPARE_VERSION([$DOXYGEN_VER],[ge],[DOXYGEN_REQ_VER],' '#'
    substituteInPlace configure.ac --replace '[AC_MSG_RESULT([$DOXYGEN_VER, yes' '#'
    substituteInPlace configure.ac --replace '[AC_MSG_RESULT([$DOXYGEN_VER, no' '# '
    ./autogen.sh
  '';

  meta = with stdenv.lib; {
    description = "An implementation of double-array structure for representing trie";
    license = licenses.lgpl2;
    homepage = https://linux.thai.net/projects/datrie;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

