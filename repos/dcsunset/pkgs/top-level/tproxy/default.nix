{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "tproxy";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "kevwan";
    repo = "tproxy";
    rev = "v${version}";
    hash = "sha256-LX3ciC3cMYuQPm6ekEkJPrSdTXH+WZ4flXyrsvJZgn8=";
  };

  vendorHash = "sha256-7s2gnd9UR/R7H5pcA8NcoenaabSVpMh3qzzkOr5RWnU=";

  meta = with lib; {
    description = "A cli tool to proxy and analyze TCP connections.";
    homepage = "https://github.com/kevwan/tproxy";
    license = licenses.mit;
    mainProgram = "tproxy";
  };
}
