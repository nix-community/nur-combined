{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  cython_0,
  pyopengl,
  glfw,
  pygame,
  pysdl2,
  click,
  numpy,
  sphinx,
  pytest_7,
  mock,
  coveralls,
  pytestCheckHook
}:


buildPythonPackage rec {
  pname = "imgui";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "pyimgui";
    repo = "pyimgui";
    tag = version;
    fetchSubmodules = true;
    hash = "sha256-sw/bLTdrnPhBhrnk5yyXCbEK4kMo+PdEvoMJ9aaZbsE=";
  };

  dependencies = [
    cython_0
    pyopengl
    numpy
    glfw
    pygame
    pysdl2
    click
  ];

  pyproject = true;
  build-system = [
    setuptools
  ];

  nativeCheckInputs = [
    # pytestCheckHook
    sphinx
    pytest_7
    mock
    coveralls
    cython_0
    click
  ];

  pythonImportsCheck = [
    # "imgui"
  ];

   meta = {
    description = "Cython-based Python bindings for dear imgui";
    homepage = "https://github.com/pyimgui/pyimgui";
    changelog = "https://github.com/pyimgui/pyimgui/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
  };
}
