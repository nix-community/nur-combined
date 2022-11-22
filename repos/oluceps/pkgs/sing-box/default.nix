{ lib
, fetchFromGitHub
, buildGoModule
,
}:
buildGoModule rec {
  pname = "sing-box";
  version = "1.1-beta12";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "ffd54eef6c71a4e847d53fb38d3622d689ea026d";
    sha256 = "sha256-vhbvg8WCKJcszwlBHD4dZA4bswevI5VBjurMzKK4VLU=";
  };

  vendorSha256 = "sha256-Wx0fiIZ3CgHFp/sWPCoot4h3IqQg59qsUlvR2Onw+2E=";

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
