{ stdenv, perl, which }:
stdenv.mkDerivation {
  name = "when";
  version = "1.1.40";

  src = builtins.fetchTarball {
    url = "http://www.lightandmatter.com/when/when.tar.gz";
    sha256 = "12d0zmvg66lwzr7q8zky0kz1x3w6q8dvyzm4x7lf1vy2z4pm4cvx";
  };

  nativeBuildInputs = [ which ];
  buildInputs = [ perl ];

  installFlags = [ "prefix=$(out)" ];

  meta = with stdenv.lib; {
    homepage = "http://www.lightandmatter.com/when/when.html";
    description = "An extremely simple personal calendar program";
    longDescription = "When is an extremely simple personal calendar program, aimed at the Unix geek who wants something minimalistic.";
    license = licenses.gpl2;
    platforms = platforms.all;
  };
}
