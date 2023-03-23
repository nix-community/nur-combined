{ stdenv
, lib
, fetchFromGitHub
, buildGoModule
, buildPackages
}:
buildGoModule rec {
  pname = "sing-box";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "f9516709dada695aea270f19fd3ab99e82a07eea";
    sha256 = "sha256-it0LdHRXA+bZ/oVViLxVXQTIxUIP4pa4sncyY3M3fX8=";
  };

  vendorHash = "sha256-a9xjAaHYe0Z2bkGNxZqEICbsVp3P/6Q7cihpNohGsds=";

  proxyVendor = true;

  # Do not build testing suit
  excludedPackages = [ "./test" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sagernet/sing-box/constant.Commit=${version}"
  ];

  CGO_ENABLED = 1;

  tags = [
    "with_quic"
    "with_grpc"
    "with_wireguard"
    "with_utls"
    "with_ech"
    "with_gvisor"
    "with_clash_api"
    "with_lwip"
  ];

  subPackages = [
    "cmd/sing-box"
  ];

  doCheck = false;

  meta = with lib; {
    description = "sing-box";
    homepage = "https://github.com/SagerNet/sing-box";
    license = licenses.gpl3Only;
    #    maintainers = with maintainers; [ oluceps ];
  };
}
