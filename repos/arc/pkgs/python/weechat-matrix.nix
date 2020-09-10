{ lib, pythonPackages, fetchFromGitHub, weechat-matrix-contrib }:

with pythonPackages;

buildPythonPackage rec {
  pname = "weechat-matrix";
  version = "2020-08-30";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = pname;
    rev = "2a79d9c38b93433e3c1c538c27bada0f1656e8ee";
    sha256 = "0lr4bn53ismh3dpdv9qwfp4214grhbcdjrh26rha8q26g0pm0pnz";
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
