{ lib, buildPythonPackage, fetchFromGitHub, flake8
, mock, python }:
buildPythonPackage rec {
  pname = "flake8-coding";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "tk0miya";
    repo = pname;
    rev = "f209792e03abb6a38e9cb40bc9f349ec4f9fd535";
    sha256 = "0lhs7rppbhxyc8jji6d4y6vxbc0lmb90nkhwc1y3s7snsn4rvagk";
  };

  propagatedBuildInputs = [ flake8 ];

  checkInputs = [ mock ];
  checkPhase = ''
    ${python}/bin/python run_tests.py
  '';
  
  meta = with lib; {
    description = "Adds coding magic comment checks to flake8";
    homepage = https://pypi.org/project/flake8-coding;
    license = licenses.asl20;
  };
}

