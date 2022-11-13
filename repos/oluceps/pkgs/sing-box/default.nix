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
    rev = "24f4dfea0491091a91d93eee8b63428346563059";
    sha256 = "sha256-nKvYemrDswqJAqBqZFOPWI+QXROMMoeL6zNw+ZenxyQ=";
  };

  vendorSha256 = "sha256-sIHoTEoDkus6oE6dSsBaPSYSPabnRtDVdoOifiLwF18=";

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
