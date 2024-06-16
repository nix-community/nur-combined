{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "jsonseq";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "sgillies";
    repo = "jsonseq";
    rev = version;
    hash = "sha256-aZu4+MRFrAizskxqMnks9pRXbe/vw4sYt92tRpjfUSg=";
  };

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Python implementation of RFC 7464";
    homepage = "https://github.com/sgillies/jsonseq";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
