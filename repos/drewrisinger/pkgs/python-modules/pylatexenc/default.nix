{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pylatexenc";
  version = "2.6";

  src = fetchFromGitHub {
    owner = "phfaist";
    repo = pname;
    rev = "v${version}";
    sha256 = "0db1k9jj02rb1amajq7kgidp5zh9p3a1sysi4fipc13vj1rwk532";
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
