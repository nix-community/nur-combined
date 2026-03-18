{ lib
, fetchurl
, buildPythonApplication
, platformdirs
}:
buildPythonApplication {
  pname = "yapf";
  version = "0.43.0";

  propagatedBuildInputs = [
    platformdirs
  ];

  format = "wheel";
  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/37/81/6acd6601f61e31cfb8729d3da6d5df966f80f374b78eff83760714487338/yapf-0.43.0-py3-none-any.whl";
    hash = "sha256-Ik+v+8OcQoywlYGM9u9VEf2rb3QwoQeD/fspLM8oUso=";
  };
  doCheck = false;
  dontBuild = true;

  meta = with lib; {
    description = "A formatter for Python files";
    mainProgram = "yapf";
    homepage = "https://github.com/google/yapf";
    license = licenses.asl20;
  };
}
