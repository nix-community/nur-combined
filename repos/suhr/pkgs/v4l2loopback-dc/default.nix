{ stdenv, writeText, fetchFromGitHub
, droidcam
, kernel, kmod
}:

stdenv.mkDerivation rec {
  name = "v4l2loopback-dc-${version}-${kernel.version}";
  inherit (droidcam) version;

  inherit (droidcam) src;

  hardeningDisable = [ "format" "pic" ];

  buildInputs = [ kmod ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  preBuild = ''
    cd linux/v4l2loopback
  '';

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  meta = with stdenv.lib; {
    description = "V4L2 loopback device module for DroidCam";
    homepage = "https://github.com/aramg/droidcam";
    license = licenses.gpl2;
    maintainers = with maintainers; [ jtojnar suhr ];
    platforms = platforms.linux;
  };
}
