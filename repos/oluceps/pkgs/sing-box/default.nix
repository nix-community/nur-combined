{ lib
, fetchFromGitHub
, buildGoModule
,
}:
buildGoModule rec {
  pname = "sing-box";
  version = "1.1-beta9";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "39c141651a145ebf4406b07cafe887978022471e";
    sha256 = "sha256-/FObbmObBE5IJ5QUKmtg/9HPWHqzMCTX6jG0fqQ7uow=";
  };

  vendorSha256 = "sha256-pOnL3ul1bgezE9RljqVrJkTkUIcNoDKGdhmz5nBC9fo=";

  # Do not build testing suit
  excludedPackages = [ "./test" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sagernet/sing-box/constant.Commit=${version}"
  ];
  
  tags = [
    "with_quic"
    "with_grpc"
    "with_wireguard"
    "with_utls"
    "with_ech"
    "with_gvisor"
    "with_clash_api"
  ];

  CGO_ENABLED = 1;
  doCheck = false;

  meta = with lib; {
    description = "sing-box";
    homepage = "https://github.com/SagerNet/sing-box";
    license = licenses.gpl3Only;
#    maintainers = with maintainers; [ oluceps ];
  };
}
