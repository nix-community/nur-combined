{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools-scm,
  isPy3k,
}:

buildPythonPackage rec {
  pname = "apipkg";
  version = "2.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-zKNAIkFKE5duM6HjjWoJBWfve2jQNy+SPGmaj4wIivw=";
  };

  nativeBuildInputs = [ setuptools-scm ];
  nativeCheckInputs = [ pytestCheckHook ];

  # Fix pytest 4 support. See: https://github.com/pytest-dev/apipkg/issues/14
  postPatch = ''
    substituteInPlace "test_apipkg.py" \
      --replace "py.test.ensuretemp('test_apipkg')" "py.path.local('test_apipkg')"
  '';

  # Failing tests on Python 3
  # https://github.com/pytest-dev/apipkg/issues/17
  disabledTests = lib.optionals isPy3k [
    "test_error_loading_one_element"
    "test_aliasmodule_proxy_methods"
    "test_eagerload_on_bython"
  ];

  meta = with lib; {
    description = "Namespace control and lazy-import mechanism";
    homepage = "https://github.com/pytest-dev/apipkg";
    license = licenses.mit;
  };
}
