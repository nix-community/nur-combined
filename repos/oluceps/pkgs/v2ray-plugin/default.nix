{ lib
, fetchFromGitHub
, buildGoModule
, ...
}:
buildGoModule {
  pname = "v2ray-plugin";
  version = "4.45.2";

  src = fetchFromGitHub {
    owner = "teddysun";
    repo = "v2ray-plugin";
    rev = "87488f188689234956407631e728faae143f3e65";
    sha256 = "sha256-QTuyMMjctnimsKxtkVjIjafQLXYc08D6UX+lwNsT6MI=";
  };

  vendorSha256 = "sha256-MBjEM2S2G+8vfFmNqCsW5SRPvX6eo9rEuluvCPln4EQ=";

  CGO_ENABLED = 0;
  doCheck = false;

  meta = with lib; {
    description = "v2ray-plugin";
    homepage = "https://github.com/teddysun/v2ray-plugin/";
    license = licenses.mit;
#    maintainers = with maintainers; [ oluceps ];
  };
}
