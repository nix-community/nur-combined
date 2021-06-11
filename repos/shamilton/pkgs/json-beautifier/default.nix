{ lib
, stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "json-beautifier";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "alula";
    repo = "json-beautifier";
    rev = version;
    sha256 = "17145959cqwgwhzi156xfsqwgh4z052f1xysyv8822gniqvbxry9";
  };

  patches = [ ./add-cmake-install.patch ];

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Argument Parser for Modern C++";
    license = licenses.mit;
    homepage = "https://github.com/p-ranav/argparse";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
