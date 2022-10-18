{ lib
, buildGo117Module
, fetchFromGitHub
}:

buildGo117Module rec {
  pname = "grpc-gateway";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "grpc-ecosystem";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-OthyGEMVQnK0jN9svlfAZUl52lt19jtLd1Oj3cuirx4=";
  };

  vendorSha256 = "sha256-UjwpFjHVaQT4irhbt2GGlYeNhDs9Dv73PcHKhMrQfQs=";
  subPackages = [ "protoc-gen-grpc-gateway" "protoc-gen-openapiv2" ];

  meta = with lib; {
    homepage = "https://github.com/grpc-ecosystem/grpc-gateway";
    changelog = "https://github.com/grpc-ecosystem/grpc-gateway/releases/tag/v${version}";
    description = "gRPC to JSON proxy generator following the gRPC HTTP spec";
    license = licenses.bsd3;
  };
}
