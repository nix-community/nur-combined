{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchPypi,
  setuptools,
  setuptools-scm,
  wheel,
  pytestCheckHook,
  hypothesis,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "pybcj";
  version = "1.0.3";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uIc2N/C+AM6qNy0PuBaTYEtLvI3s2ysa5fm4TRlniNk=";
  };

  build-system = [
    setuptools
    setuptools-scm
    wheel
  ];

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "https://codeberg.org/miurahr/pybcj";
    description = "bcj filter library";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
