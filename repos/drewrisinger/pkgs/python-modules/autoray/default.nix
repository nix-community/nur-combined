{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, numpy
  # Check Inputs
, pytestCheckHook
, pytestcov
}:

buildPythonPackage rec {
  pname = "autoray";
  version = "0.2.5";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "jcmgray";
    repo = pname;
    rev = version;
    sha256 = "sha256-/ceZtwno5et8GrXBqqCDw2ueo/F19JpG/IAa4k6eA8k=";
  };

  propagatedBuildInputs = [
    numpy
  ];

  dontUseSetuptoolsCheck = true;
  checkInputs = [ pytestCheckHook pytestcov ];

  meta = with lib; {
    description = "Write numeric code that automatically works with any numpy-ish libraries";
    homepage = "https://github.com/jcmgray/autoray";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
