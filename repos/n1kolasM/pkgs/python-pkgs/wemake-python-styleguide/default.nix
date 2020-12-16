{ stdenv, buildPythonPackage, fetchPypi
, flake8, attrs, typing-extensions, astor
, pygments, cognitive-complexity, flake8-builtins
, flake8-commas, flake8-quotes, flake8-comprehensions
, flake8-docstrings, flake8-string-format
, flake8-coding, flake8-bugbear, flake8-pep3101
, flake8-debugger, flake8-isort, flake8-eradicate
, flake8-bandit, flake8-logging-format
, flake8-broken-line, flake8-print
, flake8-annotations-complexity
, flake8-rst-docstrings, flake8-executable
, pep8-naming, radon, darglint }:
buildPythonPackage rec {
  pname = "wemake-python-styleguide";
  version = "0.13.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "033ycbqja7znhaz6hf8fq6l86qz3kswsczg06v3874byfy4gyyyw";
  };
  patches = [ ./001-flake8-fix-support.patch ];

  propagatedBuildInputs = [
    flake8
    attrs
    typing-extensions
    astor
    pygments
    cognitive-complexity
    flake8-builtins
    flake8-commas
    flake8-quotes
    flake8-comprehensions
    flake8-docstrings
    flake8-string-format
    flake8-coding
    flake8-bugbear
    flake8-pep3101
    flake8-debugger
    flake8-isort
    flake8-eradicate
    flake8-bandit
    flake8-logging-format
    flake8-broken-line
    flake8-print
    flake8-annotations-complexity
    flake8-rst-docstrings
    flake8-executable
    pep8-naming
    radon
    darglint
  ];
  meta = with stdenv.lib; {
    broken = true;
    description = "The strictest and most opinionated python linter ever";
    homepage = https://wemake-python-stylegui.de;
    license = with licenses; [ mit ];
  };
}
