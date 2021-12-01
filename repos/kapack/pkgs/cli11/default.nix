{
  lib, stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
  python3,
  boost,
  catch2
}:

stdenv.mkDerivation rec {
  pname = "cli11";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "CLIUtils";
    repo = "CLI11";
    rev = "v${version}";
    sha256 = "0z23lbxv5703390l71cr3lq21n65z33xnavkdj8qy7cs76j78pi3";
  };

  nativeBuildInputs = [ cmake ];

  checkInputs = [ boost python3 catch2 ];

  doCheck = true;

  meta = with lib; {
    description = "Command line parser for C++11";
    homepage = "https://github.com/CLIUtils/CLI11";
    platforms = platforms.unix;
    maintainers = with maintainers; [ ];
    license = licenses.bsd3;
  };

}
