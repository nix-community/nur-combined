{
  buildPythonPackage,
  fetchFromGitHub,
  lib,

  # since this is a dependency of pytest, we need to avoid
  # circular dependencies
  jinja2,
  railroad-diagrams,
}:

let
  pyparsing = buildPythonPackage (finalAttrs: {
    pname = "pyparsing";
    version = "2.4.7";
    format = "setuptools";

    src = fetchFromGitHub {
      owner = "pyparsing";
      repo = finalAttrs.pname;
      rev = "pyparsing_${finalAttrs.version}";
      hash = "sha256-0Dyzw3xiCGhLbXPcL2cq2fZuN1N5StSZ/I86gQHy7pI=";
    };

    # circular dependencies if enabled by default
    doCheck = false;
    nativeCheckInputs = [
      jinja2
      railroad-diagrams
    ];

    checkPhase = ''
      python -m unittest
    '';

    passthru.tests = {
      check = pyparsing.overridePythonAttrs (_: {
        doCheck = true;
      });
    };

    meta = {
      homepage = "https://github.com/pyparsing/pyparsing";
      description = "Alternative approach to creating and executing simple grammars, vs. the traditional lex/yacc approach, or the use of regular expressions";
      license = lib.licenses.mit;
    };
  });
in
pyparsing
