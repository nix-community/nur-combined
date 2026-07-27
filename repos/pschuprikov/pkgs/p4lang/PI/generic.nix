{ rev, sha256 }:
{ stdenv, grpc, judy, protobuf3_2, openssl, boost, pkg-config, python3, autoconf
, automake, libtool, fetchFromGitHub }:
stdenv.mkDerivation {
  name = "PI";
  src = fetchFromGitHub {
    owner = "p4lang";
    repo = "PI";
    inherit rev sha256;
    fetchSubmodules = true;
  };
  buildInputs = [ grpc judy protobuf3_2 openssl boost ];
  preConfigure = ''
    ./autogen.sh
  '';
  configureFlags = [ "--with-proto" "--with-boost-thread=boost_thread" ];
  nativeBuildInputs = [ python3 pkg-config autoconf automake libtool ];
  enableParallelBuilding = true;
}


