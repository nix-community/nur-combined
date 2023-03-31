{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "fast_float";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "fastfloat";
    repo = "fast_float";
    rev = "v${version}";
    sha256 = "sha256-02kvyr9Jw/8Ka/qkJm7KMBuZURVfGh5bBgm3pUzDN+4=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Fast header-only implementations for the C++ from_chars functions for float and double types.";
    homepage = "https://github.com/fastfloat/fast_float";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
