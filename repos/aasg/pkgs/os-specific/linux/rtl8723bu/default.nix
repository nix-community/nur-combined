{ stdenv, fetchFromGitHub, kernel, concurrentMode ? false }:

stdenv.mkDerivation rec {
  name = "rtl8723bu-${kernel.version}-${version}";
  version = "2020-04-05";

  src = fetchFromGitHub {
    owner = "lwfinger";
    repo = "rtl8723bu";
    rev = "c9549d172a4f9d6ccf6d528682640246a41c2f0c";
    sha256 = "1j5ijp9721nrh5g4gkpxchc6z2dhajhq63a0vwkbz1rmifkbzzmy";
  };

  postPatch = stdenv.lib.optionalString (!concurrentMode) ''
    sed -i '/-DCONFIG_CONCURRENT_MODE/d' Makefile
  '';

  hardeningDisable = [
    "fortify"
    "pic"
    "stackprotector"
  ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "ARCH=${stdenv.hostPlatform.platform.kernelArch}"
    "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "KVER=${kernel.version}"
    "DEPMOD=true"
    "INSTALL_MOD_PATH=$(out)"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Driver for RTL8723BU";
    longDescription = ''
      Kernel driver for Realtek RTL8723BU Wireless Adapter with hardware ID 0bda:b720.
    '';
    homepage = "https://github.com/lwfinger/rtl8723bu";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
    maintainers = with maintainers; [ AluisioASG ];
  };
}
