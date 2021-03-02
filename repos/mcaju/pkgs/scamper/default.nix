{ stdenv
, lib
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "scamper";
  version = "20200923";

  src = fetchurl {
    url = "https://www.caida.org/tools/measurement/scamper/code/scamper-cvs-${version}.tar.gz";
    sha256 = "096305ci20dr1i19yan2nmsq52fb4ky2vmgrcr82n5cnlvcqi6fw";
  };

  meta = with lib; {
    description = "Scamper is designed to actively probe destinations in the Internet in parallel (at a specified packets-per-second rate) so that bulk data can be collected in a timely fashion.";
    homepage = "https://www.caida.org/tools/measurement/scamper/";
    license = licenses.gpl2;
    platforms = platforms.unix;
  };
}
