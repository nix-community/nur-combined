{ lib
, fetchurl
, buildPythonApplication
, black
, click
, docstring-to-markdown
, importlib-metadata
, jedi
, mypy-extensions
, packaging
, parso
, pathspec
, platformdirs
, pluggy
, python-lsp-jsonrpc
, typing-extensions
, ujson
, zipp
}:
buildPythonApplication {
  pname = "python-lsp-server";
  version = "1.13.0";

  propagatedBuildInputs = [
    black
    click
    docstring-to-markdown
    importlib-metadata
    jedi
    mypy-extensions
    packaging
    parso
    pathspec
    platformdirs
    pluggy
    python-lsp-jsonrpc
    typing-extensions
    ujson
    zipp
  ];

  format = "wheel";
  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/a9/65/ab9fb9174ea65852eb01a7998ee1e373a1f5c167d2228a9dd096277678cd/python_lsp_server-1.13.0-py3-none-any.whl";
    hash = "sha256-rTqPeSkVcG3GXOH/y67TYeXmSMlzzQXlx6SpTGeP75c=";
  };
  doCheck = false;
  dontBuild = true;

  meta = with lib; {
    description = "Python implementation of the Language Server Protocol";
    mainProgram = "pylsp";
    homepage = "https://github.com/python-lsp/python-lsp-server";
    license = licenses.mit;
  };
}
