{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "rst2txt";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "stephenfin";
    repo = "rst2txt";
    rev = version;
    hash = "sha256-UqY+qD1S8tyRxvQ0GIzfBlHzsdVSaEJkmgw1WC0H/KA=";
  };

  nativeBuildInputs = with python3Packages; [ setuptools-scm ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  propagatedBuildInputs = with python3Packages; [
    docutils
    pygments
    setuptools # pkg_resources
  ];

  doCheck = false;

  meta = {
    description = "Convert reStructuredText to plain text";
    inherit (src.meta) homepage;
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
