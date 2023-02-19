{ stdenv
, lib
, fetchFromGitHub
, buildGoModule
, buildPackages
}:
buildGoModule rec {
  pname = "sing-box";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "v${version}";
    sha256 = "sha256-FEwyJL6pFdp9vXIq1TUFGGDfKefFsVaajjX2U0R5Vog=";
  };

  vendorHash = "sha256-3rq5DZO1pBQEJ7ook9AAe/swMc3VAO+5BwR7IfTvF44=";

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
