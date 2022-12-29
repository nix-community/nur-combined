{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "mouseless";
  version = "0.1.3";

  src = fetchFromGitHub {
    repo = pname;
    owner = "jbensmann";
    rev = "v${version}";
    sha256 = "sha256-IYYbYEML9QZI2b3V4g0v3Oz4QC+2lGy4K2S3SLpgZiQ=";
  };

  vendorSha256 = "sha256-5/sfhfLAVjSuzaBSmx2YmpS/c43LAV73ofHRx1UWc3o=";

  ldFlags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Replacement for the physical mouse in Linux. Successor to xmouseless";
    homepage = "https://github.com/jbensmann/mouseless";
    licenses = licenses.mit;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
