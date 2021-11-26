{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
  # Python Inputs
, cirq
, networkx
, qiskit-terra
, z3
  # Check Inputs
, pytestCheckHook
, qiskit-ibmq-provider
}:

buildPythonPackage rec {
  pname = "olsq";
  version = "0.0.4";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "tbcdebug";
    repo = pname;
    rev = "497c7a21e307d9801e9ce5d9e6c9f9599d013485"; # untagged
    sha256 = "039v2n3wz6dy0w6nihc93akz7qh887hdw4gf47lgsps83krnsd7k";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "networkx>=2.5" "networkx" \
      --replace "z3-solver>=4.8.9.0" ""
  '';

  propagatedBuildInputs = [
    cirq
    networkx
    qiskit-terra
    z3
  ];

  checkInputs = [
    pytestCheckHook
    qiskit-ibmq-provider
  ];

  pythonImportsCheck = [ "olsq" ];

  pytestFlagsArray = [
    "./test_olsq*.py"
  ];
  disabledTests = [
    # Requires IBMQ account/online access
    "devibm"
  ];

  meta = with lib; {
    description = "Optimal Layout Synthesis for Quantum Computing";
    homepage = "https://olsq.readthedocs.io/en/latest/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
