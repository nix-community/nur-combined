{ lib, stdenvNoCC, fetchFromGitHub }:
stdenvNoCC.mkDerivation {
  pname = "uboot-phicomm-n1";
  version = "unstable-2023-04-29";

  src = fetchFromGitHub ({
    owner = "cattyhouse";
    repo = "new-uboot-for-N1";
    rev = "9aa890be5f9f4109e1a9a338ab584e0fc9947d5c";
    sha256 = "sha256-R6lzd7uyAIzxwHph9jZ1y0kTr8kQA5VeCIFyAJMq+vg=";
  });

  installPhase = ''
    runHook preInstall
    mkdir -p $out/dtbs
    cp emmc_autoscript s905_autoscript uboot $out
    cp extlinux/n1.dtb $out/dtbs
    runHook postInstall
  '';

  meta = with lib; {
    description = "new version of uboot for Phicomm N1";
    homepage = "https://github.com/cattyhouse/new-uboot-for-N1";
    license = licenses.free;
  };
}
