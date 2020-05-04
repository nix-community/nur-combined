{ stdenv, writeText, fetchFromGitHub
, kernel, kmod
}:

stdenv.mkDerivation rec {
  name = "v4l2loopback-dc-${version}-${kernel.version}";
  version = "298599";

  src = fetchFromGitHub {
    owner = "suhr";
    repo = "v4l2loopback-dc";
    rev = "2985993902fb122bf3eeaeced4b6759775c33bd6";
    sha256 = "0zsxk75lcaqihzfk7hjlvh6g214xh1jc5jiyrwvqcw191q8diw8l";
  };

  hardeningDisable = [ "format" "pic" ];

  preBuild = ''
    substituteInPlace Makefile --replace "modules_install" "INSTALL_MOD_PATH=$out modules_install"
    export PATH=${kmod}/sbin:$PATH
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;
  buildInputs = [ kmod ];

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  meta = with stdenv.lib; {
    description = "V4L2 loopback device module for DroidCam";
    homepage = "https://github.com/aramg/droidcam";
    license = licenses.unfree;
    maintainers = [ maintainers.suhr ];
    platforms = platforms.linux;
  };
}
