{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "heirloom-sh";
  version = "050706";

  src = fetchurl {
    url = "mirror://sourceforge/heirloom/${pname}/${version}/${pname}-${version}.tar.bz2";
    sha256 = "07cyh0js2qspwrk8sa51hj5wpssy5npjp8qwl9fvnxgbw44q9yr5";
  };

  outputs = [ "out" "man" ];

  configurePhase = ''
    runHook preConfigure

    substituteInPlace ./makefile \
      --replace 'SV3BIN=/usr/5bin' "SV3BIN=\$($outputBin)/bin" \
      --replace 'MANDIR=/usr/share/man/5man' \
        "MANDIR=\$($outputMan)/share/man" \
      #

    substituteInPlace ./makefile \
      --replace 'UCBINST=/usr/ucb/install' 'UCBINST=install' \
      --replace 'STRIP=strip' 'STRIP=true # strip' \
      --replace 'FLAGS=' 'FLAGS?=' \
      #

    runHook postConfigure
  '';

  meta = with stdenv.lib; {
    description = "A portable variant of the traditional Unix shell";
    homepage = http://heirloom.sourceforge.net/sh.html;
    license = with licenses; [ zlib ccdl10 caldera ];
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.all;
  };
}
