{ lib
, buildPythonPackage
, fetchFromGitHub
, cmake
, darwin
, glew
, glfw
, libxcrypt
, pkg-config
, stdenv
, xorg
}:
buildPythonPackage rec {
  pname = "dearpygui";
  version = "1.9.1";
  src = fetchFromGitHub {
    owner = "hoffstadt";
    repo = "DearPyGui";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-Af1jhQYT0CYNFMWihAtP6jRNYKm3XKEu3brFOPSGCnk=";
  };
  cmakeFlags = [ "-DMVDIST_ONLY=True" ];
  postConfigure = ''
    cd $cmakeDir
    mv build cmake-build-local
  '';
  nativeBuildInputs = [ pkg-config cmake ];
  buildInputs = [
    libxcrypt
  ] ++ lib.optionals stdenv.isLinux [
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
    darwin.apple_sdk.frameworks.Cocoa
    darwin.apple_sdk.frameworks.CoreVideo
    darwin.apple_sdk.frameworks.OpenGL
    darwin.IOKit
  ];
  dontUseSetuptoolsCheck = true;
  pythonImportsCheck = [
    "dearpygui"
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
