{ lib, pythonPackages, fetchFromGitHub, weechat-matrix-contrib }:

with pythonPackages;

buildPythonPackage rec {
  pname = "weechat-matrix";
  version = "2021-02-18";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = pname;
    rev = "ef09292005d67708511a44c8285df1342ab66bd1";
    sha256 = "0rjfmzj5mp4b1kbxi61z6k46mrpybxhbqh6a9zm9lv2ip3z6bhlw";
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
    aiohttp
    typing
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
