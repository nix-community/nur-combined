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
    rev = "0e37449d1c41b4ff4ab29e49ee973bd13c96ac31";
    sha256 = "sha256-xNy2EEq1HuXkHPeHmbScWWggUdfkqX1FDO0DjbWVTls=";
  };

  vendorHash = "sha256-BTwAGyZrapO+CXbWm5sIbTtvKjlWWyWq29neILk/6xI=";

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
