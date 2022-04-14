{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, setuptools_scm
  # test inputs
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "asteval";
  version = "0.9.26";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "newville";
    repo = "asteval";
    rev = version;
    sha256 = "sha256-S8TQ1ZIczmXaIxCcvaM5QLF18xrfbz+4KBZT5kPZUVA=";
  };

  nativeBuildInputs = [
    setuptools_scm
  ];

  preBuild = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION=${version}
  '';

  pythonImportsCheck = [ "asteval" ];
  checkInputs = [ pytestCheckHook ];

  meta = with lib; {
    description = "Minimalistic evaluator of python expressions using ast module";
    homepage = "https://newville.github.io/asteval/";
    downloadPage = "https://github.com/newville/asteval/releases";
    license = licenses.mit;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
