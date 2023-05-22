{ buildPythonPackage
, pythonOlder
, fetchFromGitHub
, torch
, numpy
}:

buildPythonPackage rec {
  pname = "fairscale";
  version = "0.4.13";
  format = "setuptools";
  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "facebookresearch";
    repo = " fairscale";
    rev = "v${version}";
    hash = "";
  };

  propagatedBuildInputs = [ torch numpy ];

  doCheck = false; # no tests currently


}
