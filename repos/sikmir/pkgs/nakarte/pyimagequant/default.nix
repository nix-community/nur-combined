{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "pyimagequant";
  version = "2019-10-24";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "pyimagequant";
    rev = "a467b3b2566f4edd31a272738f7c5e646c0d84a9";
    hash = "sha256-yBtZsCaFJxPfI8EWyGatepGzE6+1BFUQ2h+ElH9Unqo=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = with python3Packages; [ cython ];

  pythonImportsCheck = [ "imagequant" ];

  meta = with lib; {
    description = "Python bindings for libimagequant (pngquant core)";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    broken = stdenv.isDarwin;
  };
}
