{ stdenv, fetchFromGitHub, numactl, pkgconfig }:

stdenv.mkDerivation rec {
  name = "opa-psm2-${version}";
  version = "10.3.58";

  preConfigure= ''
    export UDEVDIR=$out/etc/udev
    substituteInPlace ./Makefile --replace "udevrulesdir}" "prefix}/etc/udev";
  '';

  enableParallelBuilding = true;

  buildInputs = [ numactl pkgconfig ];

  installFlags = [ 
    "DESTDIR=$(out)"
    "UDEVDIR=/etc/udev"
    "LIBPSM2_COMPAT_CONF_DIR=/etc"
  ];

  src = fetchFromGitHub {
    owner = "intel";
    repo = "opa-psm2";
    rev = "PSM2_${version}";
    sha256 = "0p643df4nh9wsm9rpngwfw26pprvyy3zsclgh1mbjaaahbkp3mi7";
  };

  meta = with stdenv.lib; {
    homepage = https://github.com/intel/opa-psm2;
    description = "The PSM2 library supports a number of fabric media and stacks";
    license = stdenv.lib.licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.bzizou ];
  };
}
