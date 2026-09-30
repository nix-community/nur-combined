{ lib
, stdenvNoCC
, fetchurl
, dpkg
}:

stdenvNoCC.mkDerivation {
  pname = "manpages-ro";
  version = "4.31.0-1";

  src = fetchurl {
    url = "http://deb.debian.org/debian/pool/main/m/manpages-l10n/manpages-ro_4.31.0-1_all.deb";
    hash = "sha256-ja+bxI4WAl5lnHX7mvi+UHeNMVDmEry581BylMO2oPc=";
  };

  nativeBuildInputs = [ dpkg ];

  unpackPhase = "dpkg-deb -x $src source";

  installPhase = ''
    mkdir -p $out/share/man
    cp -a source/usr/share/man/ro $out/share/man/
  '';

  meta = with lib; {
    description = "Romanian translations of Linux manual pages";
    homepage = "https://manpages-l10n-team.pages.debian.net/manpages-l10n/";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
