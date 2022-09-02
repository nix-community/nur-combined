{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "jsonseq";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "sgillies";
    repo = "jsonseq";
    rev = version;
    hash = "sha256-aZu4+MRFrAizskxqMnks9pRXbe/vw4sYt92tRpjfUSg=";
  };

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "Python implementation of RFC 7464";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
