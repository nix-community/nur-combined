{ lib, stdenv, sources }:

stdenv.mkDerivation rec {
  inherit (sources.ubootPhicommN1) pname version src;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp emmc_autoscript s905_autoscript u-boot.emmc u-boot.ext $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "new version of uboot for Phicomm N1";
    homepage = "https://github.com/cattyhouse/new-uboot-for-N1";
    license = licenses.free;
  };
}
