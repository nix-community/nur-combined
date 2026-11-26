{ lib
, stdenvNoCC
, fetchurl
, dpkg
}:

stdenvNoCC.mkDerivation {
  pname = "manpages-ro-dev";
  version = "4.32.4-1";

  src = fetchurl {
    url = "https://deb.debian.org/debian/pool/main/m/manpages-l10n/manpages-ro-dev_4.32.4-1_all.deb";
    hash = "sha256-bZE1Rzq8U89av+bjWMi1wKyJk1wpcHVgMJ1+NszowEI=";
  };

  nativeBuildInputs = [ dpkg ];

  unpackPhase = "dpkg-deb -x $src source";

  installPhase = ''
    mkdir -p $out/share/man
    cp -a source/usr/share/man/ro $out/share/man/
  '';

  meta = with lib; {
    description = "Romanian translations of Linux development manual pages";
    homepage = "https://manpages-l10n-team.pages.debian.net/manpages-l10n/";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
