{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "lux";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "iawia002";
    repo = "lux";
    rev = "v${version}";
    sha256 = "sha256-fZR+Q0duITZq3Ynr2WTZAhDnmEkXrT2gXUlpuN0+aFo=";
  };

  vendorSha256 = "sha256-SHUtyfGRGriEaESo6th7gGQn6V4REdk3XT0ZlGwky7E=";
  subPackages = [ "." ];

  meta = with lib; {
    description = "Fast and simple video download library and CLI tool written in Go";
    homepage = "https://github.com/iawia002/lux";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
