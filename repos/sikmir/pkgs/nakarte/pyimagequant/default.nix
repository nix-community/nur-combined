{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "pyimagequant";
  version = "2022-06-10";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "pyimagequant";
    rev = "55a76cb90c75b598d40bd92cf61e6ec9aa846d1e";
    hash = "sha256-80SsAcN0iEaEEQpNTsi81n71DEQksSYiaSe/LQpqMbc=";
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
