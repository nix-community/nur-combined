{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "taskflow";
  version = "3.3.0";

  src = fetchFromGitHub {
    repo = "taskflow";
    owner = "taskflow";
    rev = "bfad4b9a0cc5acad5fc99fb6ff6b904b79f27f93";
    sha256 = "sha256-UfXGupxgtowIt3BnIVWwim3rTE57TT1C9TCx9LVyN34=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DTF_BUILD_TESTS=${if doCheck then "ON" else "OFF"}"
    "-DTF_BUILD_EXAMPLES=OFF"
  ];

  preConfigure = ''
      cmakeFlags="$cmakeFlags -DCMAKE_INSTALL_PREFIX=$out" 
  '';

  doCheck = false;

  meta = with lib; {
    description = "A general-purpose parallel and heterogeneous task programming system";
    homepage = "https://github.com/taskflow/taskflow";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
