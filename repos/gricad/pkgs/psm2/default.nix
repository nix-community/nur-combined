{ stdenv, fetchFromGitHub, numactl, pkgconfig }:

stdenv.mkDerivation rec {
  name = "opa-psm2-${version}";
  version = "11.2.78";

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
    sha256 = "0vkw5g1p3pfr58a2g7a4mk247jg07jawx9iwkikwyqgnrsrkcqg1";
  };

  meta = with stdenv.lib; {
    homepage = https://github.com/intel/opa-psm2;
    description = "The PSM2 library supports a number of fabric media and stacks";
    license = stdenv.lib.licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.bzizou ];
  };
}
