{ stdenv, fetchFromGitHub, cmake, boost, openmpi }:

stdenv.mkDerivation {
  name = "muster";
  src = fetchFromGitHub {
    owner = "LLNL";
    repo = "muster";
    rev = "b58796b62689e178008ae484829bef03e7908766";
    sha256 = "0w5054qwk970b9i37njwfsa7z7mgb9w6agyl1arx0f69wblc24is";
  };
  buildInputs = [ cmake boost openmpi ];
}

