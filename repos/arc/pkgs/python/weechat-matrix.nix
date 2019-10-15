{ lib, pythonPackages, fetchFromGitHub, weechat-matrix-contrib }:

with pythonPackages;

buildPythonPackage rec {
  pname = "weechat-matrix";
  version = "2019-09-22";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = pname;
    rev = "b26dc838ef0a69c99fab525a6647dc44c7015cb9";
    sha256 = "0miilwksm9ra460w19zgqqkqqawhsjdwawl28icwk4x3lr882rnj";
  };

  propagatedBuildInputs = [
    pyopenssl
    webcolors
    future
    atomicwrites
    attrs
    Logbook
    pygments
    matrix-nio
  ];

  passAsFile = [ "setup" ];
  setup = ''
    from io import open
    from setuptools import find_packages, setup

    with open('requirements.txt') as f:
      requirements = f.read().splitlines()

    setup(
      name='@name@',
      version='@version@',
      install_requires=requirements,
      packages=find_packages(),
    )
  '';

  weechatMatrixContrib = weechat-matrix-contrib;
  postPatch = ''
    substituteInPlace matrix/uploads.py \
      --replace matrix_upload $weechatMatrixContrib/bin/matrix_upload
    substituteAll $setupPath setup.py
  '' + lib.optionalString (!matrix-nio.enableOlm) ''
    substituteInPlace requirements.txt \
      --replace "[e2e]" ""
  '';
}
