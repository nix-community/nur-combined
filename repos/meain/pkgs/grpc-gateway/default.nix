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
  version = "2.10.3";

  src = fetchFromGitHub {
    owner = "grpc-ecosystem";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-4/iE+sK+ZbG6194i8E1ZHla/7C9blKGRHwM7iX7nvXU=";
  };

  vendorSha256 = "sha256-FhiTU9VmDZNCPBWrmCqmQo/kPdDe8Da1T2E06CVN2kw=";
  subPackages = [ "protoc-gen-grpc-gateway" "protoc-gen-openapiv2" ];

  meta = with lib; {
    homepage = "https://github.com/grpc-ecosystem/grpc-gateway";
    changelog = "https://github.com/grpc-ecosystem/grpc-gateway/releases/tag/v${version}";
    description = "gRPC to JSON proxy generator following the gRPC HTTP spec";
    license = licenses.bsd3;
  };
}
