{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pylatexenc";
  version = "2.8";

  src = fetchFromGitHub {
    owner = "phfaist";
    repo = pname;
    rev = "v${version}";
    sha256 = "0m9vrbh1gmbgq6dqm7xzklar3accadw0pn896rqsdi5jbgd3w0mh";
  };

  pythonImportsCheck = [ "pylatexenc" ];
  dontUseSetuptoolsCheck = true;
  preCheck = "pushd $TMP/$sourceRoot";
  checkInputs = [ pytestCheckHook ];

  meta = with lib; {
    description = "Simple LaTeX parser providing latex-to-unicode and unicode-to-latex conversion";
    homepage = "https://pylatexenc.readthedocs.io";
    downloadPage = "https;//www.github.com/phfaist/pylatexenc/releases";
    license = licenses.mit;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
