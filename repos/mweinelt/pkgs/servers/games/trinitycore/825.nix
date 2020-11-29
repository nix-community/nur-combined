{ clangStdenv, fetchFromGitHub, cmake, libmysqlclient, git, boost, readline, bzip2 }:

clangStdenv.mkDerivation rec {
  pname = "TrinityCore";
  version = "8.2.5-32978";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "8.2.5/32978";
    sha256 = "0pbhh52hqnc1chlps1qdgjxbn9h8h5w6mw79i7857mplfwj198zc";
  };

  nativeBuildInputs = [ cmake git ];
  buildInputs = [ libmysqlclient boost readline bzip2 ];

  cmakeFlags = [
    "-DMYSQL_HOME=${libmysqlclient}/lib/mysql"
    "-DMYSQL_INCLUDE_DIR=${libmysqlclient.dev}/include/mysql"
  ];

  meta = with clangStdenv.lib; {
    description = "TrinityCore Open Source MMO Framework";
    homepage = "https://www.trinitycore.org";
    license = licenses.gpl2;
  };
}
