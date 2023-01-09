{ python39Packages, fetchgit, ... }:
python39Packages.buildPythonPackage rec {
  pname = "imagehash";
  version = "4.2.1";

  src = fetchgit {
    url = "https://github.com/JohannesBuchner/${pname}";
    rev = "v${version}";
    hash = "sha256-ZeaOqPftUHshWKqwl4vIbVXDGD4+cWWdLHEBMRNcPn0=";
  };

  propagatedBuildInputs = with python39Packages;
    [ pillow numpy scipy pywavelets six pytest ];
}
