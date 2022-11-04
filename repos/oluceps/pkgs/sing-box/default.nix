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
    rev = "6e8c4f6576c508c8dfea472aacd2922961274ba6";
    sha256 = "sha256-sPaGb0CAs728n109ED2S12fBLsfV8C+4Fj+NAz7T4No=";
  };

  vendorSha256 = "sha256-KYesU4/61n+MsjNBv0+wOzv7FAGbqWrVxxHb6c3OEvI=";

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
