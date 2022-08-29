{ lib, stdenv, fetchFromGitHub, cmake, zstd }:

stdenv.mkDerivation rec{
  pname = "zarchive";
  version = "git";
  
  src = fetchFromGitHub {
    owner = "Exzap";
    repo = "ZArchive";
    rev = "48914a07df3c213333c580bb5e5bb3393442ca5b";
    sha256 = "MN8P1zqvOPmXcOgpw4Y0c8AvPQS3nY/HBnwS2HPEsts=";
  };
  
  nativeBuildInputs = [ cmake ];
  
  buildInputs = [ zstd ];
  
  meta = with lib; {
    description = "Library for creating and reading zstd-compressed file archives (.zar)";
    homepage = "https://github.com/Exzap/ZArchive";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
