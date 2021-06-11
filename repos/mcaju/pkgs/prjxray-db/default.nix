{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname   = "prjxray-db";
  version = "0.0-251-gc284338";

  src = fetchFromGitHub {
    owner  = "SymbiFlow";
    repo   = "prjxray-db";
    rev    = "c28433840752ff0da5b8353bfdeafed24148aa38";
    sha256 = "19mi78vvh2mm75xksmayxphz1xdiljsfhdliqx5h6f91xk0falzx";
  };

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    DBDIR="$out/share/symbiflow/prjxray-db/"
    DB_CONFIG="$out/bin/prjxray-config"

    mkdir -p $DBDIR $out/bin

    for device in artix7 kintex7 zynq7; do
      cp -a $src/$device $DBDIR
    done

    echo -e "#!/bin/sh\n\necho $DBDIR" > $DB_CONFIG
    chmod +x $DB_CONFIG

    runHook postInstall
  '';

  meta = with lib; {
    description = "Project X-Ray - Xilinx Series 7 Bitstream Documentation";
    homepage    = "https://github.com/SymbiFlow/prjxray-db";
    license     = licenses.cc0;
    platforms   = platforms.all;
  };
}
