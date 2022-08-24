{ lib
, buildGo117Module
, fetchFromGitHub
}:

buildGo117Module rec {
  pname = "grpc-gateway";
  version = "2.11.3";

  src = fetchFromGitHub {
    owner = "grpc-ecosystem";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-FGRuThptgcNttciYxNLUiY5oVoiODnXgMDiw1hz71mM=";
  };

  vendorSha256 = "sha256-8mFTswOgBTSDypgtfovJT9Xsykis7Q1CCQL751SuTY8=";
  subPackages = [ "protoc-gen-grpc-gateway" "protoc-gen-openapiv2" ];

  meta = with lib; {
    homepage = "https://github.com/grpc-ecosystem/grpc-gateway";
    changelog = "https://github.com/grpc-ecosystem/grpc-gateway/releases/tag/v${version}";
    description = "gRPC to JSON proxy generator following the gRPC HTTP spec";
    license = licenses.bsd3;
  };
}
