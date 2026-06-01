{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "eve";
  version = "unstable-2026-05-26";

  src = fetchFromGitHub {
    owner = "jfalcou";
    repo = "eve";
    rev = "93bbdee2b65092c317db2a7800e96b3b031c1ebe";
    sha256 = "sha256-ocKvc0BB3EcSsmdRIcnE0FIDaxr3u+ZIECELpD0FGRI=";
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
