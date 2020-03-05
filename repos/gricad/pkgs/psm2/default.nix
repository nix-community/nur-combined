{ stdenv, fetchFromGitHub, numactl, pkgconfig }:

stdenv.mkDerivation rec {
  name = "opa-psm2-${version}";
  version = "10_10_1_0_36";

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
    rev = "IFS_RELEASE_${version}";
    sha256 = "13qd4nln38fvc440bnwfr37bm6xniadnslxcakvj2kjn4lrlwdgn";
  };

  postInstall = ''
    mv $out/usr/* $out
    rmdir $out/usr
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/intel/opa-psm2;
    description = "The PSM2 library supports a number of fabric media and stacks";
    license = stdenv.lib.licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.bzizou ];
  };
}
