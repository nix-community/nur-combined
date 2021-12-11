{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "taskflow";
  version = "3.2.0";

  src = fetchFromGitHub {
    repo = "taskflow";
    owner = "taskflow";
    rev = "e46376dd294f355f1d3468292f709fa7beb9471c";
    sha256 = "sha256-WjUyMnwWjz2YpvZ8LPJ9N5jfSmsO3GxWeEvd7/ACiB0=";
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
