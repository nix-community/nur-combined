{ lib
, buildPythonPackage
, libtweedledum
, fetchPypi
, cmake
, ninja
, scikit-build
  # Check Inputs
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "tweedledum";
  inherit (libtweedledum) version src;
  format = "pyproject";

  nativeBuildInputs = [ cmake ninja scikit-build ];
  dontUseCmakeConfigure = true;

  pythonImportsCheck = [ "tweedledum" ];

  checkInputs = [ pytestCheckHook ];
  pytestFlagsArray = [
    "python/test"
  ];

  meta = with lib; {
    description = "A library for synthesizing and manipulating quantum circuits";
    homepage = "https://github.com/boschmitt/tweedledum";
    license = licenses.mit ;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
