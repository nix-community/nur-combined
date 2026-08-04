{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "clair-scanner";
  version = "14.0.0";

  src = fetchFromGitHub {
    owner = "arminc";
    repo = "clair-scanner";
    rev = version;
    hash = "sha256-EV1DgACUGJ/mySGqPBkh5ANRN0niq98mKDpEIeuoopo=";
  };

  vendorHash = "sha256-+DRssg9PIetPU7i61RsRxvicNcCB12aQ1DMFS7DUoqI=";

  meta = with lib; {
    description = " Docker containers vulnerability scan";
    homepage = "https://github.com/arminc/clair-scanner";
    licenses = licenses.asl20;
    mainProgram = "clair-scanner";
  };
}
