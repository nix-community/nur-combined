{ stdenv
, lib
, fetchFromGitHub
, kernel
, kmod
}: 

# from: https://ortiz.sh/linux/2020/07/05/UNKILLABLE.html

stdenv.mkDerivation rec {
  name = "unkillableKernelModule-${version}-${kernel.version}";
  version = "0.1";

  src = ./.;

  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
  ];

  meta = with lib; {
    description = "A kernel module that makes a char-device /dev/unkillable, from which you can read($your_pid) from, which then makes your process unkillable. code from: https://ortiz.sh/linux/2020/07/05/UNKILLABLE.html";
    homepage = "https://ortiz.sh/linux/2020/07/05/UNKILLABLE.html";
    license = licenses.gpl2;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
