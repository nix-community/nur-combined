{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
  # Python Inputs
, matplotlib
, numpy
, qiskit-terra
, scipy
  # Check Inputs
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "qiskit-ode";
  version = "unstable-2021-04-12";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "qiskit-ode";
    rev = "21fed791780886ffe1490cf255c2078cc162520a";
    sha256 = "1aijmg39gnj1yma4d406zichdjwyrrvp8aiampv4kffmj4ly6p24";
  };

  propagatedBuildInputs = [
    matplotlib
    numpy
    qiskit-terra
    scipy
  ];

  checkInputs = [ pytestCheckHook ];
  dontUseSetuptoolsCheck = true;

  pythonImportsCheck = [ "qiskit_ode" ];

  disabledTests = [
    # These tests fail "TypeError: ufunc 'nextafter' not supported for the input types, and the inputs could not be safely coerced to any supported types according to the casting rule ''safe''"
    "test_solve_ode_w_GeneratorModel"
    "test_standard_problems_solve_ivp"
  ];

  meta = with lib; {
    description = "ODE solver tools in Qiskit";
    homepage = "https://qiskit.org";
    downloadPage = "https://github.com/qiskit/qiskit-ode";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
