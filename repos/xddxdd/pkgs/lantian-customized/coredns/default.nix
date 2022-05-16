{ lib
, buildGoModule
, fetchFromGitHub
, ...
} @ args:

buildGoModule rec {
  pname = "coredns-lantian";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "coredns";
    rev = "b7afdedb3e8ff5f0454687b6d1eb726d5f1847dc";
    sha256 = "sha256-H8RQ8xHJNjthAN6Pg4k/0qy69fZRnIadsU0GXQorwlI=";
  };

  vendorSha256 = "sha256-w5i0L998GteIqYtgpuiy+sa3z4B/vVZujQnSlmXWUCM=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/xddxdd/coredns";
    description = "CoreDNS with Lan Tian's modifications";
    license = licenses.asl20;
  };
}
