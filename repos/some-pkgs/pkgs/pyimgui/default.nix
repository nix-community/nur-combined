{ lib
, buildPythonPackage
, fetchFromGitHub
, python
, pkg-config
, cython
, setuptools
, wheel
, click
, pyopengl
, stdenv
, xorg
, glfw
, glew
, Cocoa
, OpenGL
, CoreVideo
, IOKit
}:
buildPythonPackage rec {
  name = "pyimgui";
  version = "1.4.0";
  src = fetchFromGitHub {
    owner = "pyimgui";
    repo = "pyimgui";
    rev = version;
    fetchSubmodules = true;
    sha256 = "sha256-H6B7x+sTPy4zy/UHPjKOV6A8u2wjNhAIfkrKJSyJLDY=";
  };
  doCheck = false;
  buildPhase = ''
    python setup.py build bdist_wheel
  '';
  nativeBuildInputs = [
    pkg-config
    setuptools
    wheel
    cython
    pyopengl
    glfw
    glew
    click
  ];
  propagatedBuildInputs = [
    pyopengl
    glfw
    glew
    click
  ];
  buildInputs = lib.optionals stdenv.isLinux [
    xorg.libX11.dev
    xorg.libXrandr.dev
    xorg.libXinerama.dev
    xorg.libXcursor.dev
    xorg.xinput
    xorg.libXi.dev
    xorg.libXext
  ] ++ lib.optionals stdenv.isDarwin [
    Cocoa
    OpenGL
    CoreVideo
    IOKit
  ];
  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.bsd3;
    description = "Cython-based Python bindings for dear imgui";
    homepage = "https://pyimgui.readthedocs.io";
    broken = stdenv.isDarwin;
    platforms = lib.platforms.unix;
  };
}
