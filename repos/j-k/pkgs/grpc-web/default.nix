{ lib, stdenv, fetchFromGitHub, fetchpatch, protobuf }:

stdenv.mkDerivation rec {
  pname = "grpc-web";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "grpc";
    repo = pname;
    rev = version;
    sha256 = "sha256-NBENyc01O8NPo84z1CeZ7YvFvVGY2GSlcdxacRrQALw=";
  };

  patches = [
    (fetchpatch {
      name = "add-prefix";
      url = "https://patch-diff.githubusercontent.com/raw/grpc/grpc-web/pull/1107.patch";
      sha256 = "sha256-RNrg/ltdu9whAdfBrObiKvL8ebv22SkT/9HspHL940U=";
    })
  ];

  postPatch = ''
    cd ./javascript/net/grpc/web/
  '';

  nativeBuildInputs = [ protobuf ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    homepage = "https://github.com/google/go-containerregistry/tree/main/cmd/crane";
    description = "A tool for interacting with remote images and registries";
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
