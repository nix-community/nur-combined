{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "eve";
  version = "unstable-2026-06-29";

  src = fetchFromGitHub {
    owner = "jfalcou";
    repo = "eve";
    rev = "39a07c77527ded5aa00468d7a7daec2c7ca6caad";
    sha256 = "sha256-sS5fmLEvZNNQvBAA+1m8axOOJWr6jjOm1O9D/WAQuKU=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DEVE_BUILD_TEST=OFF" "-DEVE_BUILD_BENCHMARKS=OFF" "-DEVE_BUILD_DOCUMENTATION=OFF" ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "EVE - the Expressive Vector Engine in C++20.";
    homepage = "https://github.com/jfalcou/eve";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
