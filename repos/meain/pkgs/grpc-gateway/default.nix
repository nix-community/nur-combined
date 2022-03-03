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
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "grpc-ecosystem";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-8eBBBYJ+tBjB2fgPMX/ZlbN3eeS75e8TAZYOKXs6hcg=";
  };

  vendorSha256 = "sha256-8XbFKsgmMcf363W/F1Ffh1eEh/M3NGg0zzLCZ4b5Dho=";
  subPackages = [ "protoc-gen-grpc-gateway" "protoc-gen-openapiv2" ];

  meta = with lib; {
    homepage = "https://github.com/grpc-ecosystem/grpc-gateway";
    changelog = "https://github.com/grpc-ecosystem/grpc-gateway/releases/tag/v${version}";
    description = "gRPC to JSON proxy generator following the gRPC HTTP spec";
    license = licenses.bsd3;
  };
}
