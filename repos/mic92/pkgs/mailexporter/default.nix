{ lib, fetchFromGitHub, buildGoModule }:
buildGoModule rec {
  # https://github.com/cherti/mailexporter
  pname = "mailexporter";
  version = "2021-04-17";

  src = fetchFromGitHub {
    owner = "cherti";
    repo = "mailexporter";
    rev = "f46e4f87aec7c3b3a47745f467e2671f030f6684";
    sha256 = "sha256-vIQIj4joD32ym3DKio8XOSffql7bgO6G+RL/0oC6+5o=";
  };

  vendorHash = "sha256-QOOf00uCdC8fl7V/+Q8X90yQ7xc0Tb6M9dXisdGEisM=";

  meta = with lib; {
    description = "Export Prometheus-style metrics about mail server functionality";
    inherit (src.meta) homepage;
    license = licenses.mit;
  };
}
