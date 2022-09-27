{ lib
, fetchFromGitHub
, buildGoModule
,
}:
buildGoModule rec {
  pname = "sing-box";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "2373281c4122726b08af6f6ece56c0319d14dd0d";
    sha256 = "sha256-qKPMFDoWJTl8fZG9gvyC+PGBiUTy+80V0/E0kFTic+8=";
  };

  vendorSha256 = "sha256-IkrB70U8l3l11YdUq/V/GqjVk8E8z9WmtivvFtfb4js=";

  # Do not build testing suit
  excludedPackages = [ "./test" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sagernet/sing-box/constant.Commit=${version}"
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
