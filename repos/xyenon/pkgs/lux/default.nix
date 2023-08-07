{ lib, fetchFromGitHub, buildGoModule, nix-update-script }:

buildGoModule rec {
  pname = "lux";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "iawia002";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-klm1985qBErFfYIWPjr1/n6nYr/jA9dbrDMfw4bf1tM=";
  };

  vendorSha256 = "sha256-7wgGJYiIsVTRSuSb4a9LgYCkkayGhNMKqcIKoDxMuAM=";

  subPackages = [ "." ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Fast and simple video download library and CLI tool written in Go";
    homepage = "https://github.com/iawia002/lux";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
