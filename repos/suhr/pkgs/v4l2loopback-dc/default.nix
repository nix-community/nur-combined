{ stdenv, writeText, fetchFromGitHub
, kernel, kmod
}:

stdenv.mkDerivation rec {
  name = "v4l2loopback-dc-${version}-${kernel.version}";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "aramg";
    repo = "droidcam";
    rev = "v${version}";
    sha256 = "06ly609szf87va3pjchwivrnp9g93brgzpwfnb2aa97qllam8lbn";
  };

  hardeningDisable = [ "format" "pic" ];

  buildInputs = [ kmod ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  preBuild = ''
    cd linux/v4l2loopback
    substituteInPlace Makefile --replace "modules_install" "INSTALL_MOD_PATH=$out modules_install"
    export PATH=${kmod}/sbin:$PATH
  '';

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  meta = with stdenv.lib; {
    description = "V4L2 loopback device module for DroidCam";
    homepage = "https://github.com/aramg/droidcam";
    license = licenses.gpl2;
    maintainers = [ maintainers.suhr ];
    platforms = platforms.linux;
  };
}
