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
  version = "0.2.3";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "jcmgray";
    repo = pname;
    rev = version;
    sha256 = "07srcx3lwaqmnpyklpxixxq8vnkpl4y35cgwzr5480l60idnznbh";
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
