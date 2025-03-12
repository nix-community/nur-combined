{ lib, stdenv, fetchFromGitHub, numactl, pkg-config }:

stdenv.mkDerivation rec {
  name = "opa-psm2-${version}";
  version = "11.2.185";

  preConfigure= ''
    export UDEVDIR=$out/etc/udev
    substituteInPlace ./Makefile --replace "udevrulesdir}" "prefix}/etc/udev";
  '';

  enableParallelBuilding = true;

  buildInputs = [ numactl pkg-config ];

  installFlags = [ 
    "DESTDIR=$(out)"
    "UDEVDIR=/etc/udev"
    "LIBPSM2_COMPAT_CONF_DIR=/etc"
  ];

  src = fetchFromGitHub {
    owner = "cornelisnetworks";
    repo = "opa-psm2";
    rev = "PSM2_${version}";
    sha256 = "062hg4r6gz7pla9df70nqs5i2a3mp1wszmp4l0g771fykhhrxsjg";
  };

  postInstall = ''
    mv $out/usr/* $out
    rmdir $out/usr
  '';

  meta = with lib; {
    homepage = https://github.com/intel/opa-psm2;
    description = "The PSM2 library supports a number of fabric media and stacks";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.bzizou ];
  };
}
