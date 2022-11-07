{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "lux";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "iawia002";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-kB625R6Qlo9sw0iz8MbaCFOjxpMyH+9ugC6JDn7L7eM=";
  };

  vendorSha256 = "sha256-2cH5xVz3k9PPjzoMjWch3o8VBfP4nWAvakNwZNQLOeI=";
  subPackages = [ "." ];

  meta = with lib; {
    description = "Fast and simple video download library and CLI tool written in Go";
    homepage = "https://github.com/iawia002/lux";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
