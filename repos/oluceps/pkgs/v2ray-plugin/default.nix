{ lib
, fetchFromGitHub
, buildGoModule
, ...
}:
buildGoModule rec {
  pname = "v2ray-plugin";
  version = "4.45.2";

  src = fetchFromGitHub {
    owner = "teddysun";
    repo = "v2ray-plugin";
    rev = "60b3d965be58ee01b5d8d8ff00a1b60b8d1a9361";
    sha256 = "sha256-/vF08H3ZmD7HJhCSeHFepYcazr6jjdJgtP9K7vIunlU=";
  };

  vendorSha256 = "sha256-QV1lTdvqP/KY0yPwLnEi704bNFy+Fcw9M+mUbe/HYmU=";

  CGO_ENABLED = 0;
  doCheck = false;

  meta = with lib; {
    description = "v2ray-plugin";
    homepage = "https://github.com/teddysun/v2ray-plugin/";
    license = licenses.mit;
#    maintainers = with maintainers; [ oluceps ];
  };
}
