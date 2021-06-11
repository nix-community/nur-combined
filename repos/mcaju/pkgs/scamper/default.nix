{ stdenv
, lib
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "scamper";
  version = "20210324";

  src = fetchurl {
    url = "https://ftp.openbsd.org/pub/OpenBSD/distfiles/scamper-cvs-${version}.tar.gz";
    sha256 = "0124rz96nzr5m2p25hcapggdbfgqvajawgrwvm2k1h07lw8wwb9k";
  };

  meta = with lib; {
    description = "Scamper is designed to actively probe destinations in the Internet in parallel (at a specified packets-per-second rate) so that bulk data can be collected in a timely fashion.";
    homepage = "https://www.caida.org/tools/measurement/scamper/";
    license = licenses.gpl2;
    platforms = platforms.unix;
  };
}
