{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {

  pname = "clair-scanner";
  version = "unstable-2021-11-10";

  src = fetchFromGitHub {
    owner = "arminc";
    repo = "clair-scanner";
    rev = "31e23875fdd032ff79440d7ca3cb39211aa2b4f9";
    sha256 = "sha256-nkGFct1mccXeDPO3sV1Tz33AJhaKkpXuFkAXK6r01kw=";
  };

  vendorSha256 = "sha256-p5QlUdkjf6Ky9ZWbKLUO3/GH9bvwghNS3HQHSZAfuOk=";

  meta = with lib; {
    description = " Docker containers vulnerability scan";
    homepage = "https://github.com/arminc/clair-scanner";
    licenses = licenses.asl20;
    maintainers = with maintainers; [ wolfangaukang ];
  };
}
