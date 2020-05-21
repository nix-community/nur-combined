{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
  # test inputs
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "asteval";
  version = "0.9.18";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "newville";
    repo = "asteval";
    rev = version;
    sha256 = "1dbxqvxn6pv1ga4916s0djnd1qxs24ph5xc0bicvsqf1k8giiz9r";
  };

  pythonImportsCheck = [ "asteval" ];
  dontUseSetuptoolsCheck = true;
  checkInputs = [ pytestCheckHook ];
  preCheck = "pushd $TMP/$sourceRoot";
  postCheck = "popd";

  meta = with lib; {
    description = "Minimalistic evaluator of python expressions using ast module";
    homepage = "https://newville.github.io/asteval/";
    downloadPage = "https://github.com/newville/asteval/releases";
    license = licenses.mit;
    # maintainers = with maintainers; [ drewrisinger ];
  };
}
