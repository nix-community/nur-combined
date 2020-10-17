{ llvmPackages_11, lib, fetchFromGitHub, cmake, libmysqlclient, git, boost, readline, bzip2 }:

llvmPackages_11.stdenv.mkDerivation rec {
  pname = "TrinityCore";
  version = "TDB837.20081";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    sha256 = "1y456346wdlyyizsj8wzlzdcc0j0p2rgf94hsqib2brbqc5zyyv8";
  };

  nativeBuildInputs = [ cmake git ];
  buildInputs = [ libmysqlclient boost readline bzip2 ];

  meta = with lib; {
    description = "TrinityCore Open Source MMO Framework";
    homepage = "https://www.trinitycore.org";
    license = licenses.gpl2;
  };
}
