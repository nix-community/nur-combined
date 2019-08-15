{ stdenv, fetchFromGitHub, cmake }:
stdenv.mkDerivation rec {
  pname = "libuInputPlus";
  version = "0.1.3";

  nativeBuildInputs = [ cmake ];

  src = fetchFromGitHub {
    owner = "YukiWorkshop";
    repo = pname;
    rev = "v${version}";
    sha256 = "1am2a89kznv399id4yy4q19yyl7qz66na6wswklwhah0znh2y76i";
  };
}
