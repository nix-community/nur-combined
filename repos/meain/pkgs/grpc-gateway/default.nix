{ lib
, buildGoModule
, fetchFromGitHub
, protobuf
, git
, testVersion
, buf
}:

buildGoModule rec {
  pname = "grpc-gateway";
  version = "2.7.2";

  src = fetchFromGitHub {
    owner = "grpc-ecosystem";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-txgxzMyUKrUidYKzaIja1MA2Qi0lISl4d0FgY0AKGj4=";
  };

  vendorSha256 = "sha256-MkENPe7R0XPmnXKe2Q3+eX0qc84N0CDU74dBrMGKP/w=";
  subPackages = [ "protoc-gen-grpc-gateway" "protoc-gen-openapiv2" ];

  meta = with lib; {
    homepage = "https://grpc-ecosystem.github.io/grpc-gateway/";
    changelog = "https://github.com/grpc-ecosystem/grpc-gateway/releases/tag/v${version}";
    description = "gRPC to JSON proxy generator following the gRPC HTTP spec";
    license = licenses.bsd3;
  };
}
