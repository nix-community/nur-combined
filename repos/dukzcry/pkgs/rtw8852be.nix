{ stdenv, lib, fetchFromGitHub, kernel ? null, bc }:

with lib;

let modDestDir = "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtw8852be";

in stdenv.mkDerivation rec {
  pname = "rtw8852be";
  version = "2022-10-10";

  src = fetchFromGitHub {
    owner = "lwfinger";
    repo = "rtw8852be";
    rev = "8046f59a7eb4a311fcdd7e6f4a0ff81a353bc1c4";
    sha256 = "sha256-evpJ47hOCJ7s22Ap3o+tZ7gFlQCWH6ta9Ubz7TCl2wU=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ bc ];

  makeFlags = kernel.makeFlags ++ [ "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    mkdir -p ${modDestDir}
    find . -name '*.ko' -exec cp --parents {} ${modDestDir} \;
    find ${modDestDir} -name '*.ko' -exec xz -f {} \;

    runHook postInstall
  '';

  meta = with lib; {
    description = "Linux driver for RTW8852BE PCIe card";
    homepage = src.meta.homepage;
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    broken = (kernel == null);
    maintainers = with maintainers; [ ];
  };
}
