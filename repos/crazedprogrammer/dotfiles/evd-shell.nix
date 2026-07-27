# Environment for the EVD course.

{ pkgs ? import <nixpkgs> {}, mkShell ? true }:

let
  mPythonPackages = pkgs.python3Packages;
  buildInputs = with pkgs;
    [
      clang
      cmake
      pkg-config
      llvm
      clang-analyzer
      clang-tools
      valgrind
      gdb
      ddd

      doxygen
      graphviz
      gtest

      gtkmm3
      pcre
      (opencv4.override {
        enableGtk2 = true;
        enablePython = true;
        pythonPackages = mPythonPackages;
      })
      mPythonPackages.python
      mPythonPackages.autopep8

      qtcreator
      qt5.full
      qt5.qtquickcontrols2
      qt5.qtquickcontrols
      qt5.qtdoc
    ];
    buildScript = ''
      export CC=clang
      export CXX=clang++
      export XDG_DATA_DIRS=$XDG_DATA_DIRS:$GSETTINGS_SCHEMAS_PATH
    '';
in

if mkShell then
  pkgs.mkShell {
    buildInputs = buildInputs;
    shellHook = buildScript;
  }
else
  pkgs.stdenv.mkDerivation {
    name = "evd-shell";
    phases = [ "buildPhase" ];
    buildInputs = buildInputs;
    buildPhase = "echo $PATH > $out";
  }
