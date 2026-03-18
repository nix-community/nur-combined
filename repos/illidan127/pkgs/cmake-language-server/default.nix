{ lib
, fetchurl
  , buildPythonApplication
  , attrs
  , cattrs
  , lsprotocol
  , pygls
  , typing-extensions
}:
buildPythonApplication {
  pname = "cmake-language-server";
  version = "0.1.11";

  propagatedBuildInputs = [
    attrs
    cattrs
    lsprotocol
    pygls
    typing-extensions
  ];

  format = "wheel";
  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/60/b8/0ea1c0b86b8c6ca6c2dd5292762f282e779d6631c0641d043123bf8be164/cmake_language_server-0.1.11-py3-none-any.whl";
    hash = "sha256-dM4fqTo9slh3bYgZNRcqhxJO1iEphASsQvlg6ra+jAQ=";
  };
  doCheck = false;
  dontBuild = true;

  meta = with lib; {
    description = "cmake-language-server";
    mainProgram = "cmake-language-server";
    homepage = "https://github.com/regen100/cmake-language-server";
    license = licenses.mit;
  };
}
