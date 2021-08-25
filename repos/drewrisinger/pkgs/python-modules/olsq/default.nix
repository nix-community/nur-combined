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
  version = "0.0.3";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "tbcdebug";
    repo = pname;
    rev = "00b8132cc91d7aaca1f064aae69e04a57158b20e"; # untagged
    sha256 = "04n48glngxbyxg3f55flyvpzb1m9qgl2lsmad4zflddgf9yx7lg9";
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
  dontUseSetuptoolsCheck = true;

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
