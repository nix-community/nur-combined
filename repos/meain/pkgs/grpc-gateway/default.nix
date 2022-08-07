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
  version = "2.11.2";

  src = fetchFromGitHub {
    owner = "grpc-ecosystem";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-ouL3qxBzhsQYXTHTeNM3Ezxo72XY9KwTXNYPlLUr4nU=";
  };

  vendorSha256 = "sha256-1db3Ar3UtHS/MkhiaLt7wHuCCg8qGGL7jOHZXh1TywI=";
  subPackages = [ "protoc-gen-grpc-gateway" "protoc-gen-openapiv2" ];

  meta = with lib; {
    homepage = "https://github.com/grpc-ecosystem/grpc-gateway";
    changelog = "https://github.com/grpc-ecosystem/grpc-gateway/releases/tag/v${version}";
    description = "gRPC to JSON proxy generator following the gRPC HTTP spec";
    license = licenses.bsd3;
  };
}
