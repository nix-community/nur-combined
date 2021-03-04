{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pylatexenc";
  version = "2.9";

  src = fetchFromGitHub {
    owner = "phfaist";
    repo = pname;
    rev = "v${version}";
    sha256 = "1kzfyhdpm3cw3g4mgd12nj0cs1kgqjr22yxr7vkawljaid4ail5z";
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
