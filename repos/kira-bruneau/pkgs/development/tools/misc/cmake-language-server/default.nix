{ lib
, stdenv
, buildPythonApplication
, fetchFromGitHub
, poetry
, pygls
, pyparsing
, cmake
, pytest-datadir
, pytestCheckHook
}:

buildPythonApplication rec {
  pname = "cmake-language-server";
  version = "unstable-2021-03-28";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "regen100";
    repo = pname;
    rev = "a5af5b505f8810760168dc250caf8404370b15c3";
    hash = "sha256-uRn4Sl81ZdMZprYlDQcjNN/rl8SAm6Po7yZd3CtP4kA=";
  };

  nativeBuildInputs = [ poetry ];
  propagatedBuildInputs = [ pygls pyparsing ];

  checkInputs = [ cmake pytest-datadir pytestCheckHook ];
  dontUseCmakeConfigure = true;
  pythonImportsCheck = [ "cmake_language_server" ];

  meta = with lib; {
    description = "CMake LSP Implementation";
    homepage = "https://github.com/regen100/cmake-language-server";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    broken = stdenv.isDarwin; # pygls hangs at tests/test_protocol.py on darwin
  };
}
