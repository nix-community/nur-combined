{ stdenvNoCC, dpkg, lib, fetchurl, tree }:

stdenvNoCC.mkDerivation rec {
  pname = "libpci-dev";
  version = "3.13.0-1+b1";
  arch = "amd64";

  src = fetchurl {
    url = "http://ftp.fr.debian.org/debian/pool/main/p/pciutils/${pname}_${version}_${arch}.deb";
    sha256 = "sha256-ceNDassfgQsGyB9pdpus80C1BqXPMFLr6Z9MJq7xViI=";
  };

  nativeBuildInputs = [ dpkg tree ];

  unpackPhase = ''
    dpkg -x $src .
  '';

  installPhase = ''
    mkdir -p $out
    cp -r usr/* $out/
    tree $out
  '';

  meta = with lib; {
    description = "Development files for libpci";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
