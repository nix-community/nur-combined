{ lib
, stdenv
, fetchFromGitHub
, cmake
}:
stdenv.mkDerivation rec {

  pname = "argparse";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "p-ranav";
    repo = "argparse";
    rev = "v${version}";
    sha256 = "09wp0i835g6a80w67a0qa2mlsn81m4661adlccyrkj7rby5hnz3c";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Argument Parser for Modern C++";
    license = licenses.mit;
    homepage = "https://github.com/p-ranav/argparse";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
