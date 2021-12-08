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
  pname = "qiskit-dynamics";
  version = "0.2.0";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "qiskit-dynamics";
    rev = version;
    sha256 = "sha256-H0snJrKV4IvloE+pXc8wk9M62B31dJupvhL+1M8lvWM=";
  };

  propagatedBuildInputs = [
    matplotlib
    numpy
    qiskit-terra
    scipy
  ];

  checkInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "qiskit_dynamics" ];

  disabledTests = [
    # These tests fail "TypeError: ufunc 'nextafter' not supported for the input types, and the inputs could not be safely coerced to any supported types according to the casting rule ''safe''"
    # "test_solve_ode_w_GeneratorModel"
    # "test_standard_problems_solve_ivp"
  ];

  meta = with lib; {
    description = "ODE solver tools in Qiskit";
    homepage = "https://qiskit.org";
    downloadPage = "https://github.com/qiskit/qiskit-ode";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
