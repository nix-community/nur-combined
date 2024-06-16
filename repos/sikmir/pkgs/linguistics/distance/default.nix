{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  pname = "distance";
  version = "2013-11-22";

  src = fetchFromGitHub {
    owner = "doukremt";
    repo = "distance";
    rev = "ad7f9dc7e9b0e88a08d0cefd1442f4ab1dd1779b";
    hash = "sha256-nu/vT1KHlhHJVE92L16laBH2fzlUy9al78j4ZkABlu0=";
  };

  #setupPyBuildFlags = [ "--with-c" ];

  doCheck = false;

  pythonImportsCheck = [ "distance" ];

  meta = {
    description = "Utilities for comparing sequences";
    homepage = "https://github.com/doukremt/distance";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
