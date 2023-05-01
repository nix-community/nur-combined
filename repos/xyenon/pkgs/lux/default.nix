{ lib, fetchFromGitHub, buildGoModule }:

let
  pname = "lux";
  version = "0.18.0";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "iawia002";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-A3DDKpoaZlDUpafAGs5zCknhTeCuwMPnyBHtxke0Bi8=";
  };

  vendorSha256 = "sha256-7wgGJYiIsVTRSuSb4a9LgYCkkayGhNMKqcIKoDxMuAM=";
  subPackages = [ "." ];

  meta = with lib; {
    description = "Fast and simple video download library and CLI tool written in Go";
    homepage = "https://github.com/iawia002/lux";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
