{ lib
, buildPythonPackage
, fetchFromGitHub
, pkg-config
, cmake
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
  name = "dearpygui";
  version = "1.1.3";
  src = fetchFromGitHub {
    owner = "hoffstadt";
    repo = "DearPyGui";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-e100RIpNtfaEPtCa1ngvlW9Jlf12qxlBWszsV3tLOlc=";
  };
  cmakeFlags = [ "-DMVDIST_ONLY=True" ];
  postConfigure = ''
    cd $cmakeDir
    mv build cmake-build-local
  '';
  nativeBuildInputs = [ pkg-config cmake ];
  buildInputs = lib.optionals stdenv.isLinux [
    xorg.libX11.dev
    xorg.libXrandr.dev
    xorg.libXinerama.dev
    xorg.libXcursor.dev
    xorg.xinput
    xorg.libXi.dev
    xorg.libXext
    # are in submodules but well cmake and setuptools are hell of a couple
    glfw
    glew
  ] ++ lib.optionals stdenv.isDarwin [
    Cocoa
    OpenGL
    CoreVideo
    IOKit
  ];
  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.mit;
    description = ''
      Dear PyGui: A fast and powerful Graphical User Interface Toolkit for Python with minimal dependencies
    '';
    homepage = "https://dearpygui.readthedocs.io/en/";
    broken = stdenv.isDarwin;
    platforms = lib.platforms.unix;
  };
}
