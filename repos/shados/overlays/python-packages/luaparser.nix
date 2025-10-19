{
  lib,
  pins,
  buildPythonPackage,
  antlr4-python3-runtime,
  multimethod,
}:

buildPythonPackage rec {
  pname = "luaparser";
  version = pins.py-lua-parser.rev;

  src = pins.py-lua-parser.outPath;

  propagatedBuildInputs = [
    antlr4-python3-runtime
    multimethod
  ];

  meta = with lib; {
    description = "A Lua parser and AST builder written in Python";
    homepage = "https://github.com/boolangery/py-lua-parser";
    license = licenses.mit;
    maintainer = with maintainers; [ arobyn ];
  };
}
