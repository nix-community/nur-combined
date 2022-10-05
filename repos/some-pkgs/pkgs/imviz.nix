{ lib
, cmake
, buildPythonPackage
, fetchFromGitHub
, python
, pybind11
, pkg-config
, cython
, setuptools
, wheel
, zarr
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

let
  implot_src =
    let
      pname = "implot";
      version = "0.13";
    in
    fetchFromGitHub {
      owner = "epezent";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-fv4HYj48y94q7ulLszrvNeI7aVG5vw6joJ56erQQ58U=";
    };
in
buildPythonPackage rec {
  pname = "imviz";
  version = "unstable-2022-08-12";

  src = fetchFromGitHub {
    owner = "joruof";
    repo = "imviz";
    rev = "e662fb407e346a1f0f18deac9675ceffac906e3b";
    fetchSubmodules = true;
    hash = "sha256-45fX92EkG0X6BnM/sYN0kELQnBOB1bhbhP5ZDzOxHxE=";
  };

  preConfigure = ''
    sed -i \
      -e '/include(FetchContent/,/message(STATUS "Loading implot/d' \
      -e '/FetchContent_MakeAvailable(implot.*$/d' \
      -e 's/FetchContent_MakeAvailable(pybind.*$/find_package(pybind11 REQUIRED)/' \
      -e '/pybind11_add_module/i message(STATUS ''${SOURCE_FILES})' \
      CMakeLists.txt
    sed -i \
      -e '/try:/,/move from temp. build/d' \
      -e 's/self.build_temp/"."/g' \
      -e '/install_requires/,/]/d' \
      setup.py
  '';
  dontUseCmakeBuildDir = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    setuptools
    wheel
    cython
  ];
  buildInputs = [
    pyopengl
    glfw
    glew
    pybind11
  ] ++
  lib.optionals stdenv.isLinux [
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
  propagatedBuildInputs = [
    pyopengl
    zarr
  ];

  doCheck = false;
  cmakeFlags = [
    "-S ."
    "-B ."
    "-Dimplot_SOURCE_DIR=${implot_src}"
  ];
  buildPhase = ''
    cmake --build .
    python setup.py build bdist_wheel
  '';

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.mit;
    description = "Python bindings for imgui+implot";
    homepage = "https://pyimgui.readthedocs.io";
    platforms = lib.platforms.unix;
  };
}
