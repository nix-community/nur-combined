{ lib
, fetchFromGitHub
, python3 }:

python3.pkgs.buildPythonPackage rec {
  pname = "biblib";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "colour-science";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "065ihxlc3pjiyaw4pbkc8y30jrn2r36li3xncb86ggkfc2mg9r4s";
  };

  meta = with lib; {
    description = "Parser for BibTeX bibliographic databases";
    homepage = "https://github.com/colour-science/biblib";
    license = licenses.mit;
    maintainers = with maintainers; [ dschrempf ];
  };
}
