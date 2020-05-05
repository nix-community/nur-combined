{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pylatexenc";
  version = "2.3";

  src = fetchFromGitHub {
    owner = "phfaist";
    repo = pname;
    rev = "v${version}";
    sha256 = "0dz4jm9qy81jxz3d6k2lwsgvzs558gzbbzc73b5d4j1lydn9c78x";
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