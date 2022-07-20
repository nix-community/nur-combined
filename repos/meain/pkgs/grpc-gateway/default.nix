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
  version = "2.11.0";

  src = fetchFromGitHub {
    owner = "grpc-ecosystem";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Z3eZFd53c4cZG7CL3FrXQLi2n9A5TfUnZiB9KoA6sF4=";
  };

  vendorSha256 = "sha256-PKeqjr5MZWK6ILizwRJ7oy6eUj3cH9ju/55cbS5LT8M=";
  subPackages = [ "protoc-gen-grpc-gateway" "protoc-gen-openapiv2" ];

  meta = with lib; {
    homepage = "https://github.com/grpc-ecosystem/grpc-gateway";
    changelog = "https://github.com/grpc-ecosystem/grpc-gateway/releases/tag/v${version}";
    description = "gRPC to JSON proxy generator following the gRPC HTTP spec";
    license = licenses.bsd3;
  };
}
