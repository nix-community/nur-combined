{
  lib,
  python3,
  fetchFromGitHub,
}:
let
  python = python3;
  pname = "vicinity";
  version = "v0.4.4";
  sha256 = "sha256-VRDCtPjuuEXeiJ2r4PqCDGnTyYlb3OVeemsN9VrS6Wc=";
in
python.pkgs.buildPythonPackage {
  inherit pname version;


  src = fetchFromGitHub {
    owner = "MinishLab";
    repo = pname;
    rev = version;
    inherit sha256;
  };

  meta = {
    description = "Lightweight Nearest Neighbors with Flexible Backends";
    homepage = "https://github.com/MinishLab/vicinity";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };

  pyproject = true;

  build-system = with python.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python.pkgs; [
    numpy
    orjson
    tqdm
  ];
}