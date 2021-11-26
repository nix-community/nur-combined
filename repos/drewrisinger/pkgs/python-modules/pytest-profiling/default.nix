{ lib
, buildPythonPackage
, fetchPypi
, gprof2dot
, graphviz  # TODO: remove once https://github.com/NixOS/nixpkgs/pull/143220 gets to stable branch
, pytest
, setuptools-git
  # Check Inputs
, pytestCheckHook
, pytest-virtualenv
}:

buildPythonPackage rec {
  pname = "pytest-profiling";
  version = "1.7.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "93938f147662225d2b8bd5af89587b979652426a8a6ffd7e73ec4a23e24b7f29";
  };

  nativeBuildInputs = [ setuptools-git ];
  propagatedBuildInputs = [
    gprof2dot
    pytest
    graphviz
  ];

  checkInputs = [ pytestCheckHook pytest-virtualenv ];
  pytestFlagsArray = [
    "--ignore=tests/integration/test_profile_integration.py"  # fails, virtualenv isn't working
  ];

  meta = with lib; {
    description = "Profiling plugin for py.test";
    homepage = "https://github.com/man-group/pytest-plugins";
    license = licenses.mit;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
