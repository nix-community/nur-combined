{ pythonPackages, fetchFromGitHub }:

pythonPackages.buildPythonPackage rec {
  pname = "GAPLexer";
  version = "1.1";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "yurrriq";
    repo = "gap-pygments-lexer";
    rev = "034ef506e4bb6a09cafa3106be0c8d8aab5ce091";
    sha256 = "11bcwdl1019psvqb13fbgacr7z9y51dw78mnqq975fbiglqy88r1";
  };

  propagatedBuildInputs = [
    pythonPackages.pygments
  ];

}
