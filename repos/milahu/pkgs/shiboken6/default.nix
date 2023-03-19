{ buildPythonPackage, python, fetchurl, lib, stdenv, pyside6
, cmake, qt6, llvmPackages }:

stdenv.mkDerivation rec {
  pname = "shiboken6";

  inherit (pyside6) version src;

  patches = [
    #./nix_compile_cflags.patch
  ];

  postPatch = ''
    cd sources/${pname}
  '';

  CLANG_INSTALL_DIR = llvmPackages.libclang.out;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ llvmPackages.libclang python qt6.qtbase qt6.qtxmlpatterns ];

  cmakeFlags = [
    "-DBUILD_TESTS=OFF"
  ];

  dontWrapQtApps = true;

  postInstall = ''
    rm $out/bin/shiboken_tool.py
  '';

  meta = with lib; {
    description = "Generator for the pyside6 Qt bindings";
    license = with licenses; [ gpl2 lgpl21 ];
    homepage = "https://wiki.qt.io/Qt_for_Python";
    maintainers = with maintainers; [ gebner ];
    broken = stdenv.isDarwin;
  };
}
