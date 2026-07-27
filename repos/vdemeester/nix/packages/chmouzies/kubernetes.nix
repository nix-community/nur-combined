# https://github.com/chmouel/chmouzies/tree/master/kubernetes
{ stdenv, fetchFromGitHub, python310 }:

stdenv.mkDerivation rec {
  name = "chmouzies.kubernetes";

  src = fetchFromGitHub {
    owner = "chmouel";
    repo = "chmouzies";
    rev = "27bda8604ae51d3a4846f382475999f301c33285";
    sha256 = "sha256-atMxidonT5gjIo9Lt79G/MaA0ixi/i94Ehuw+kOC34E=";
  };

  propagatedBuildInputs = [ python310 ];

  builder = ./builder.kubernetes.sh;
}
