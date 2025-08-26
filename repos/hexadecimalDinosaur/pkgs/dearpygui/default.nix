{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  cmake,
  glfw3,
  libxcrypt
}:


buildPythonPackage rec {
  pname = "dearpygui";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "hoffstadt";
    repo = "DearPyGui";
    tag = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-YkLco717xgNwzje53/xa/p1EJI3YO9E54Xkee8OXU2w=";
  };

  patches = [
    ./cmake.patch
  ];

  dependencies = [
    glfw3
    libxcrypt
  ];

  dontUseCmakeConfigure = true;

  pyproject = true;
  build-system = [
    setuptools
    wheel
  ];

  nativeBuildInputs = [ cmake ];

  pythonImportsCheck = [
    "dearpygui.dearpygui"
  ];

   meta = {
    description = "A fast and powerful Graphical User Interface Toolkit for Python with minimal dependencies";
    homepage = "https://github.com/hoffstadt/DearPyGui";
    changelog = "https://github.com/hoffstadt/DearPyGui/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
  };
}
