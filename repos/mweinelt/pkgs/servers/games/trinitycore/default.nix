{ clangStdenv, fetchFromGitHub, cmake, libmysqlclient, git, boost, readline, bzip2 }:

clangStdenv.mkDerivation rec {
  pname = "TrinityCore";
  version = "TDB335.20051";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    sha256 = "1s64abhjimf5bbry98rxhkyflglrczzfqw6i28ay76d6aci7k16a";
  };

  nativeBuildInputs = [ cmake git ];
  buildInputs = [ libmysqlclient boost readline bzip2 ];

  meta = with clangStdenv.lib; {
    description = "TrinityCore Open Source MMO Framework";
    homepage = "https://www.trinitycore.org";
    license = licenses.gpl2;
  };
}
