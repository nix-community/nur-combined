{ llvmPackages_11, lib, fetchFromGitHub, cmake, libmysqlclient, git, boost, readline, bzip2 }:

llvmPackages_11.stdenv.mkDerivation rec {
  pname = "TrinityCore";
  version = "TDB830.20061";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    sha256 = "06fiphs5j3jzr0fc4j16shja9cdifah6syq28wyfx0gr33i6xyf6";
  };

  nativeBuildInputs = [ cmake git ];
  buildInputs = [ libmysqlclient boost readline bzip2 ];

  meta = with lib; {
    description = "TrinityCore Open Source MMO Framework";
    homepage = "https://www.trinitycore.org";
    license = licenses.gpl2;
  };
}
