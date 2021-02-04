{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "blind";
  version = "1.1";

  src = fetchurl {
    url = "https://dl.suckless.org/tools/blind-${version}.tar.gz";
    sha256 = "0nncvzyipvkkd7zlgzwbjygp82frzs2hvbnk71gxf671np607y94";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Collection of command line video editing utilities";
    homepage = "https://tools.suckless.org/blind/";
    license = licenses.isc;
    platforms = platforms.linux;
    maintainers = [ maintainers.sikmir ];
  };
}
