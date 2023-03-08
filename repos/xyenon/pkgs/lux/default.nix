{ lib, fetchFromGitHub, buildGoModule }:

let
  pname = "lux";
  version = "0.17.0";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "iawia002";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-n6oWItz0tnhpyPBGsf4+fYGnJyeYyhI2owkLrJWu7uw=";
  };

  vendorSha256 = "sha256-4pn6JKE+VieadhDLkVhbJc6XSm95cNwoNBWYGEZl8iI=";
  subPackages = [ "." ];

  meta = with lib; {
    description = "Fast and simple video download library and CLI tool written in Go";
    homepage = "https://github.com/iawia002/lux";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
