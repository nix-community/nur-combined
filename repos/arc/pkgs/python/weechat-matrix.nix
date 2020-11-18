{ lib, pythonPackages, fetchFromGitHub, weechat-matrix-contrib }:

with pythonPackages;

buildPythonPackage rec {
  pname = "weechat-matrix";
  version = "2020-11-11";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = pname;
    rev = "81be90c7c97ee9b1ff41dd9ffd9b7eb97d751c0d";
    sha256 = "126zz4203x3d277vwxalilih5m1llqyd5xgdlk7zw3bdczghrwjs";
  };

  propagatedBuildInputs = [
    pyopenssl
    webcolors
    future
    atomicwrites
    attrs
    Logbook
    pygments
    requests
    python_magic
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
    substituteInPlace matrix/server.py \
      --replace matrix_sso_helper $weechatMatrixContrib/bin/matrix_sso_helper
    substituteAll $setupPath setup.py
  '' + lib.optionalString (!matrix-nio.enableOlm) ''
    substituteInPlace requirements.txt \
      --replace "[e2e]" ""
  '';
}
