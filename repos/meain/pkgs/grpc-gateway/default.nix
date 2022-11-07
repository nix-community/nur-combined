{ lib
, buildGo117Module
, fetchFromGitHub
}:

buildGo117Module rec {
  pname = "grpc-gateway";
  version = "2.13.0";

  src = fetchFromGitHub {
    owner = "grpc-ecosystem";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-bJfqBXi77C0sa6ww0hNOwXYINp6q+KN02LdIHtlHp9Q=";
  };

  vendorSha256 = "sha256-Rr7O5pQntuvHfBurPW8FfJQmBWZOmVx7jPCu8HOs0ac=";
  subPackages = [ "protoc-gen-grpc-gateway" "protoc-gen-openapiv2" ];

  meta = with lib; {
    homepage = "https://github.com/grpc-ecosystem/grpc-gateway";
    changelog = "https://github.com/grpc-ecosystem/grpc-gateway/releases/tag/v${version}";
    description = "gRPC to JSON proxy generator following the gRPC HTTP spec";
    license = licenses.bsd3;
  };
}
