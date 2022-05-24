{ lib
, buildGo117Module
, fetchFromGitHub
, protobuf
, git
, testVersion
, buf
}:

buildGo117Module rec {
  pname = "grpc-gateway";
  version = "2.10.2";

  src = fetchFromGitHub {
    owner = "grpc-ecosystem";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-jnTerliLiBgaIMlhc3O0TkFuQ9qIL5rz8x1G+sKy8+U=";
  };

  vendorSha256 = "sha256-AxyE9Xh3NDy4CbG6JRdfMkTf1b62/XKqVmp8N6Vpo5M=";
  subPackages = [ "protoc-gen-grpc-gateway" "protoc-gen-openapiv2" ];

  meta = with lib; {
    homepage = "https://github.com/grpc-ecosystem/grpc-gateway";
    changelog = "https://github.com/grpc-ecosystem/grpc-gateway/releases/tag/v${version}";
    description = "gRPC to JSON proxy generator following the gRPC HTTP spec";
    license = licenses.bsd3;
  };
}
