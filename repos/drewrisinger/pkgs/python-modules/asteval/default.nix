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
  version = "0.9.25";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "newville";
    repo = "asteval";
    rev = version;
    sha256 = "sha256-Jy+4NifItCGI1Jj25VakwoJcrpZw0Ng4cArf2M31WGs=";
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
