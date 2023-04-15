{ lib, stdenv, sources }:

stdenv.mkDerivation rec {
  inherit (sources.ubootPhicommN1) pname version src;

  outputs = [ "out" "dtb" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp emmc_autoscript s905_autoscript uboot $out
    mkdir -p $dtb/dtbs
    cp extlinux/n1.dtb $dtb/dtbs
    runHook postInstall
  '';

  meta = with lib; {
    description = "new version of uboot for Phicomm N1";
    homepage = "https://github.com/cattyhouse/new-uboot-for-N1";
    license = licenses.free;
  };
}
