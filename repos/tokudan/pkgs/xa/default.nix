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
    description = "xa is a high-speed, two-pass portable cross-assembler. It understands mnemonics and generates code for NMOS 6502s (such as 6502A, 6504, 6507, 6510, 7501, 8500, 8501, 8502 ...), CMOS 6502s (65C02 and Rockwell R65C02) and the 65816.";
    homepage    = https://www.floodgap.com/retrotech/xa/;
    license     = licenses.gpl2;
    maintainers = with maintainers; [ tokudan ];
  };
}

