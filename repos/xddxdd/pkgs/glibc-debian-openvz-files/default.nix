{ lib
, stdenv
, dpkg
, fetchurl
, unzip
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "glibc-debian-openvz-files";
  version = "2.28-9910.0";

  src = fetchurl {
    url = "https://github.com/sdwru/glibc-debian-10/releases/download/${version}/glibc_${version}+custom1.1_amd64.deb.zip";
    sha256 = "1c3pb15jcz3p50py0j72i33v3az2hbwaginflfkiwpbk36a68510";
  };

  dontUnpack = true;

  nativeBuildInputs = [ dpkg ];

  installPhase = ''
    mkdir -p $out/binary
    ${unzip}/bin/unzip $src -d $out/binary
    find $out/binary -type f -and -not -name \*.deb -exec rm {} \;
    cd $out
    dpkg-scanpackages $out | gzip -9c > $out/Packages.gz
  '';

  meta = with lib; {
    description = "glibc for Debian v10 including 2.6.32 kernel compatibility as required when using OpenVZ v6";
    homepage = "https://github.com/sdwru/glibc-debian-10";
  };
}
