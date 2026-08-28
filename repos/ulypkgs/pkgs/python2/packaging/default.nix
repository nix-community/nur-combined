{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyparsing,
  six,
  pytestCheckHook,
  pretend,
}:

# We keep 20.4 because it uses setuptools instead of flit-core
# which requires Python 3 to build a universal wheel.

buildPythonPackage (finalAttrs: {
  pname = "packaging";
  version = "20.4";
  format = "setuptools";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Q1f3T0e5wS25NiSoIVTpsSD6gpNpmUkVKyIGXVVgefg=";
  };

  propagatedBuildInputs = [
    pyparsing
    six
  ];

  checkInputs = [
    pytestCheckHook
    pretend
  ];

  # Prevent circular dependency
  doCheck = false;

  meta = with lib; {
    description = "Core utilities for Python packages";
    homepage = "https://github.com/pypa/packaging";
    license = [
      licenses.bsd2
      licenses.asl20
    ];
    maintainers = with maintainers; [ bennofs ];
  };
})
