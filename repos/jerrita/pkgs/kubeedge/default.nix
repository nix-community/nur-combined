{
  fetchFromGitHub,
  buildGoModule,
  lib,
}:
buildGoModule rec {
  pname = "kubeedge";
  version = "1.18.0";

  src = fetchFromGitHub {
    owner = "kubeedge";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-XTYG8jiZD+YsNwejNWgR1WgdhVflN9hJJH3u3OVHYqo=";
  };

  vendorHash = null;
  subPackages = [
    "keadm/cmd/keadm"
    "edge/cmd/edgecore"
  ];

  meta = {
    description = "An open platform to enable Edge computing";
    homepage = "https://kubeedge.io";
    license = lib.licenses.asl20;
    platform = lib.platforms.linux;
  };
}
