{
  lib,
  buildPythonPackage,
  fetchPypi,
  glibcLocales,
  setuptools-scm,
  wcwidth,
}:

buildPythonPackage (finalAttrs: {
  pname = "prettytable";
  version = "1.0.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-a7f1OZA8sDH+y4VbYVy8rIzSRevG+lHG4jqzOG24l3E=";
  };

  nativeBuildInputs = [ setuptools-scm ];
  buildInputs = [ glibcLocales ];

  propagatedBuildInputs = [ wcwidth ];

  preCheck = ''
    export LANG="en_US.UTF-8"
  '';

  # no test no longer available in pypi package
  doCheck = false;
  pythonImportsCheck = [ "prettytable" ];

  meta = with lib; {
    description = "Simple Python library for easily displaying tabular data in a visually appealing ASCII table format";
    homepage = "http://code.google.com/p/prettytable/";
    license = licenses.bsd3;
  };

})
