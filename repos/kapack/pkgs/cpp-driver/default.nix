{ stdenv, lib, fetchFromGitHub, cmake, libuv, openssl, zlib }:

stdenv.mkDerivation rec {
  name =  "cpp-driver-${version}";
  version = "2.15.2";
  

  src = fetchFromGitHub {
    owner = "datastax";
    repo = "cpp-driver";
    rev = "d50636732ca3c3227e420818366544827df300f8";
    sha256 = "sha256-8Qtn5t5ers18NgVkKFYTGrk8UsL1YMz/jtePzGEHpEc=";
  };

  buildInputs = [ cmake libuv openssl zlib ];
  
  cmakeFlags = [ "-DLIBUV_ROOT_DIR=${libuv}" ];

  meta = with lib; {
    homepage = "https://docs.datastax.com/en/developer/cpp-driver";
    description = "DataStax C/C++ Driver for Apache Cassandra® and DataStax Products";
    license = licenses.asl20;
    platforms = platforms.linux;
    broken = true;
  };
}
