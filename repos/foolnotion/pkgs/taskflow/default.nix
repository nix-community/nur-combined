{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "taskflow";
  version = "3.5.0";

  src = fetchFromGitHub {
    repo = "taskflow";
    owner = "taskflow";
    rev = "v${version}";
    sha256 = "sha256-UUWJENGn60YQdUSQ55uL+/3xt/JUsVuKnqm/ef7wPVM=";
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
