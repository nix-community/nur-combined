{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "gtl";
  version = "unstable-2026-10-24";

  src = fetchFromGitHub {
    owner = "greg7mdp";
    repo = "gtl";
    rev = "086db6687a8d5bfe40219a54343f35316d4f588b";
    sha256 = "sha256-L9wJSYldkXAkFpNIX+GRw0TLO4l/ciMevtZ5iC9WN9c=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DGTL_INSTALL=ON"
    "-DGTL_BUILD_TESTS=OFF"
    "-DGTL_BUILD_EXAMPLES=OFF"
    "-DGTL_BUILD_BENCHMARKS=OFF"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Greg's template library of useful classes";
    homepage = "https://github.com/greg7mdp/gtl";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
