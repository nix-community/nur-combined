{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pylatexenc";
  version = "2.10";

  src = fetchFromGitHub {
    owner = "phfaist";
    repo = pname;
    rev = "v${version}";
    sha256 = "0hsjjgqckf1r4q31app5mrq9kl5mbf9m108zmnkdj2p6mbi38ynw";
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
