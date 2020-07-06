{ lib, pythonPackages, fetchFromGitHub, weechat-matrix-contrib }:

with pythonPackages;

buildPythonPackage rec {
  pname = "weechat-matrix";
  version = "2020-07-02";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = pname;
    rev = "439389db4d709fb069a49611173b62d67d3ad112";
    sha256 = "0sp3hjjjrsdwnd38112xvcy2inbx92i9xg7xd0gx9i4jbh79ngnl";
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
