{ stdenv, fetchurl,
}:

stdenv.mkDerivation rec {
  name = "xa-${version}";
  version = "2.3.11";

  src = fetchurl {
    url = "https://www.floodgap.com/retrotech/xa/dists/xa-${version}.tar.gz";
    sha256 = "0b81r7mvzqxgnbbmhixcnrf9nc72v1nqaw19k67221g3k561dwij";
  };

  patches = [  ];
  buildInputs = [  ];
  makeFlags = [ "DESTDIR=$(out)" ];

  postInstall = ''
    cp -Rv doc $out/share
    '';

  meta = with stdenv.lib; {
    description = "";
    homepage    = https://www.floodgap.com/retrotech/xa/;
    license     = licenses.gpl2;
    maintainers = with maintainers; [ tokudan ];
  };
}

