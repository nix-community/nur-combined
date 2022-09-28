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
    rev = "3105b8c9208850e887d157c5b3d1727b4dfe0a60";
    sha256 = "sha256-S1a78qXnAE+CoKN8yKjPJdHXmojGXce7oGrexIH8Y8c=";
  };

  vendorSha256 = "sha256-nHtYTCd59rMIcstFjw62dxVH6CJl91yx9EBz2FrwSoo=";

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
