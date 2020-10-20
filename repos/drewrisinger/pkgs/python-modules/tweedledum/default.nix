{ lib
, buildPythonPackage
, fetchPypi
, cmake
, scikit-build
  # Check Inputs
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "tweedledum";
  version = "0.1b0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "705093191342a4b50d17271bf10e6fe6c87ae1907adf64498b62aac88911ca27";
  };

  nativeBuildInputs = [ cmake scikit-build ];
  dontUseCmakeConfigure = true;
  dontUseSetuptoolsCheck = true;  # tries to run CMake check, doesn't work.

  pythonImportsCheck = [ "tweedledum" ];

  meta = with lib; {
    description = "A library for synthesizing and manipulating quantum circuits";
    homepage = "https://github.com/boschmitt/tweedledum";
    license = licenses.mit ;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
