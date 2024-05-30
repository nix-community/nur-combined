
{ lib, stdenv, fetchFromGitHub, cmake, git }:

stdenv.mkDerivation rec {
  pname = "ned14-status-code";
  version = "0.1.0.0";

  src = fetchFromGitHub {
    owner = "ned14";
    repo = "status-code";
    rev = "a35d88d692a23a89a39d45dee12a629fffa57207";
    sha256 = "sha256-t36ryLI3LYY7Wb7Ouj96DiCjiRD8N5PuaRcX+smaR30=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Library to eliminate all the tedious hassle when making state-of-the-art C++ 14 - 23 libraries.";
    homepage = "https://github.com/ned14/quickcpplib";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
