{ lib, fetchFromGitHub, python3Packages, setuptools, setuptools_scm, pymatting
, filetype, scikitimage, installShellFiles, pillow
# my fork does not need these packages
# , flask
# , tqdm
# , waitress
# , requests
, pytorch, torchvision }:

python3Packages.buildPythonPackage rec {
  pname = "rembg";
  version = "unstable-2021-12-25";

  src = fetchFromGitHub {
    #   owner = "danielgatis";
    owner = "nagy";
    repo = "rembg";
    rev = "d16d0fa1930d3ea09e2563519b36b3d007cfbe53";
    sha256 = "sha256-RJDvvSkmk2H+KrbOa79DewfaTq+0rHQorIuKTP+u2hQ=";
  };

  pythonImportsCheck = [ "rembg" ];

  nativeBuildInputs = [ setuptools_scm installShellFiles ];

  propagatedBuildInputs = [
    pymatting
    filetype
    scikitimage
    pytorch
    torchvision

    # my fork does not need these packages
    # requests
    # flask
    # tqdm
    # waitress

  ];

  meta = with lib; {
    description = "A tool to remove images background";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
