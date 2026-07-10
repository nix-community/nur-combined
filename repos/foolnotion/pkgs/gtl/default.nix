{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "gtl";
  version = "unstable-2026-07-02";

  src = fetchFromGitHub {
    owner = "greg7mdp";
    repo = "gtl";
    rev = "bf28b50e276a9b4d6c01af2d92878801e43920f7";
    sha256 = "sha256-BUj/F+ZPJ51gVYM5c/PUIjI7fo5yk/tRmUn1Kvn+AXw=";
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
