{ stdenv, lib, fetchFromGitHub, kernel, kmod }:

stdenv.mkDerivation rec {
  name = "dm-sflc-${version}-${kernel.version}";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "shufflecake";
    repo = "dm-sflc";
    rev = "v${version}";
    sha256 = "";
  };

  sourceRoot = "./.";
  # hardeningDisable = [ "pic" "format" ];                                             # 1
  nativeBuildInputs = kernel.moduleBuildDependencies;                       # 2

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"                                 # 3
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"    # 4
    "INSTALL_MOD_PATH=$(out)"                                               # 5
  ];

  meta = with lib; {
    description = "The kernel module implementing the Shufflecake scheme as a device-mapper target for the Linux kernel";
    homepage = "https://codeberg.org/shufflecake/dm-sflc";
    license = licenses.gpl3;
    maintainers = [ maintainers.oluceps ];
    platforms = platforms.linux;
  };
}
