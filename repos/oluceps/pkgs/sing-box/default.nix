{ lib
, fetchFromGitHub
, buildGoModule
,
}:
buildGoModule rec {
  pname = "sing-box";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "8ce244dd0482abc3d7c580feac12596b05fc3cfb";
    sha256 = "sha256-ER+d5YYOSG08ZPHew48yR/BMqT+1+k7pdNwi42g9hug=";
  };

  vendorSha256 = "sha256-vzdJp9w5zL7H5cnn9KwGyghGhvxqxBa//jPV1mujOgk=";

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
