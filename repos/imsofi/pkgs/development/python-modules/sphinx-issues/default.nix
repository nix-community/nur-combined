{ lib
, buildPythonPackage
, fetchFromGitHub
, sphinx
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "sphinx_issues";
  version = "3.0.1";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "sloria";
    repo = "sphinx-issues";
    rev = "${version}";
    sha256 = "sha256-CsJDeuHX11+UaqrEvLNOvcXjjkj+cUk+4ozPhHU02tI=";
  };

  propagatedBuildInputs = [ sphinx ];

  checkInputs = [ pytestCheckHook ];

  disabledTests = [
    # Asks for `/bin/sphinx-build` in a hardcoded way.
    "test_sphinx_build_integration"
  ];

  pythonImportsCheck = [ "sphinx_issues" ];

  meta = with lib; {
    description = "A Sphinx extension for linking to your project's issue tracker";
    homepage = "https://github.com/sloria/sphinx-issues";
    license = licenses.mit;
    maintainers = with maintainers; [ imsofi ];
  };
}
