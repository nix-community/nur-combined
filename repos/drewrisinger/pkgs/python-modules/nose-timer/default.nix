{ lib
, buildPythonPackage
, fetchFromGitHub
, isPy27
, nose
# Check Inputs
, mock
, parameterized
, termcolor
}:

buildPythonPackage rec {
  pname = "nose-timer";
  version = "1.0.0";

  # must download from GitHub to get the Cmake & C source files
  src = fetchFromGitHub {
    owner = "mahmoudimus";
    repo = pname;
    rev = "v${version}";
    sha256 = "0s1d1wpagwvnk6s6s8ra100998ppnagqnhaxkam95bnn722ib3b1";
  };

  disabled = isPy27;

  propagatedBuildInputs = [
    nose
  ];

  checkInputs = [
    mock
    parameterized
    termcolor
  ];

  meta = with lib; {
    description = "TODO";
    homepage = "";
    license = licenses.mit;
    # maintainers = with maintainers; [ drewrisinger ];
  };
}
