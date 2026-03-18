{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "tlfloat";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "shibatch";
    repo = "tlfloat";
    rev = "v${version}";
    hash = "sha256-ryxbtFwmUD2FfDMEohwuGAYTgGNqyTUK/J38Of2Fx9U=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DBUILD_TESTS=OFF"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "C++ template library for floating point operations";
    homepage = "https://github.com/shibatch/tlfloat";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
