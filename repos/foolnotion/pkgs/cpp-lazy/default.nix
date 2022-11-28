{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "cpp-lazy";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "MarcDirven";
    repo = "cpp-lazy";
    rev = "v${version}";
    sha256 = "sha256-3v7Pk6luazVvLbBpjvSW811ONHhtv3cJKS03kMnxG74=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCPP-LAZY_USE_STANDALONE=ON"
  ];

  meta = with lib; {
    description = "A fast C++11/14/17/20 header only library for lazy evaluation and function tools";
    homepage = "https://github.com/MarcDirven/cpp-lazy";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
