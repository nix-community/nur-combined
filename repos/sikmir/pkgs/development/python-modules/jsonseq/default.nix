{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "jsonseq";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sgillies";
    repo = "jsonseq";
    tag = finalAttrs.version;
    hash = "sha256-aZu4+MRFrAizskxqMnks9pRXbe/vw4sYt92tRpjfUSg=";
  };

  build-system = with python3Packages; [ setuptools ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Python implementation of RFC 7464";
    homepage = "https://github.com/sgillies/jsonseq";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
