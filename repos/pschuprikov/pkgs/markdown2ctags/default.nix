{ buildPythonApplication, fetchFromGitHub, setuptools }:
buildPythonApplication rec {
  pname = "markdown2ctags";
  version = "0.3.1";

  propagatedBuildInputs = [ setuptools ];

  src = fetchFromGitHub {
    owner = "jszakmeister";
    repo = "markdown2ctags";
    rev = "v${version}";
    sha256 = "4J6UZT+Sw0/YocQpoFQL7tCgijIXXidLzKDjS4IBD6o=";
  };
}
