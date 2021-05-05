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

  # TODO: remove in next version
  postPatch = ''
    substituteInPlace setup.py --replace "where='python'" "where='python', exclude=('test',)"
  '';

  nativeBuildInputs = [ cmake ninja scikit-build ];
  dontUseCmakeConfigure = true;

  pythonImportsCheck = [ "tweedledum" ];

  # TODO: use pytest, but had issues with finding the correct directories
  checkPhase = ''
    python -m unittest discover -s ./python/test -t .
  '';

  meta = with lib; {
    description = "A library for synthesizing and manipulating quantum circuits";
    homepage = "https://github.com/boschmitt/tweedledum";
    license = licenses.mit ;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
