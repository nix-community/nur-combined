{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "rtl-gopow";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "dhogborg";
    repo = "rtl-gopow";
    rev = "v${version}";
    sha256 = "sha256-QCnxvIwfv+MIgc/SO8dlvMDnGAmLQrsI23fRwE8oMLM=";
  };

  vendorSha256 = "sha256-xm3wtPdlFEAB8qCWaZpfrvSgWM8ZA8kgXfb1rgbRlAA=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/dhogborg/rtl-gopow";
    description = "Render tables from rtl_power to a nice heat map";
    license = licenses.gpl3;
  };
}
