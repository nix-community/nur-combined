{
  pkgs,
  sources,
  pythonPkgs ? pkgs.python3Packages,
  ...
}:
pythonPkgs.buildPythonPackage {
  inherit (sources.py-slvs) pname version src;
  pyproject = true;

  nativeBuildInputs = with pkgs; [
    swig
  ];

  propagatedBuildInputs = with pythonPkgs; [
    cmake
    ninja
    setuptools
    scikit-build
  ];

  dontUseCmakeConfigure = true;

  meta = with pkgs.lib; {
    description = "Python binding of SOLVESPACE geometry constraint solver";
    homepage = "https://github.com/realthunder/slvs_py";
    license = licenses.gpl3;
  };
}
