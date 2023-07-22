
{ lib, stdenv, fetchFromGitHub, cmake, git }:

stdenv.mkDerivation rec {
  pname = "ned14-quickcpplib";
  version = "0.1.0.0";

  src = fetchFromGitHub {
    owner = "ned14";
    repo = "quickcpplib";
    rev = "5f33a37e9686b87b10f560958e7f78aff64624e4";
    sha256 = "sha256-GU8l0YDapvO/CqT7Ckno1HzJhM5hD8p6hAzX9jtL6T0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake git ];

  meta = with lib; {
    description = "Library to eliminate all the tedious hassle when making state-of-the-art C++ 14 - 23 libraries.";
    homepage = "https://github.com/ned14/quickcpplib";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
