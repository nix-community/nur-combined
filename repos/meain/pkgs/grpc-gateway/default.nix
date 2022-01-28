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
  version = "2.7.3";

  src = fetchFromGitHub {
    owner = "grpc-ecosystem";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Zz0LaQN4g7v97R2uyu03BCf6t2fqFnnfjFlju4XyB8g=";
  };

  vendorSha256 = "sha256-2K5mRrjGLta2N63hAwsBZXME8vSxIoXWubJe2eZRWP0=";
  subPackages = [ "protoc-gen-grpc-gateway" "protoc-gen-openapiv2" ];

  meta = with lib; {
    homepage = "https://github.com/grpc-ecosystem/grpc-gateway";
    changelog = "https://github.com/grpc-ecosystem/grpc-gateway/releases/tag/v${version}";
    description = "gRPC to JSON proxy generator following the gRPC HTTP spec";
    license = licenses.bsd3;
  };
}
