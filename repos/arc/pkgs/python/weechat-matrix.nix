{ lib, pythonPackages, weechat-matrix, fetchFromGitHub, enableOlm ? true }:

with pythonPackages;

buildPythonPackage rec {
  pname = "weechat-matrix";
  inherit (weechat-matrix) version src;

  propagatedBuildInputs = [
    pyopenssl
    webcolors
    atomicwrites
    attrs
    Logbook
    pygments
    requests
    python_magic
    (matrix-nio.overridePythonAttrs (old: {
      version = "2022-09-13";
      src = fetchFromGitHub {
        owner = "poljar";
        repo = "matrix-nio";
        rev = "9acf5edd7b11a69d03e5dbf36cbda0f19ad25636";
        sha256 = "sha256-QL4mvvoYG1M01sPRJZCaCDIVVHUKCFDGXW79N4HiL88=";
      };
    }))
  ] ++ lib.optional (pythonOlder "3.5") typing
  ++ lib.optional (pythonOlder "3.2") future
  ++ lib.optional (pythonAtLeast "3.5") aiohttp;

  passAsFile = [ "setup" ];
  setup = ''
    from io import open
    from setuptools import find_packages, setup

    with open('requirements.txt') as f:
      requirements = f.read().splitlines()

    setup(
      name='@pname@',
      version='@version@',
      install_requires=requirements,
      packages=find_packages(),
      scripts=['contrib/matrix_upload.py', 'contrib/matrix_sso_helper.py'],
    )
  '';

  postPatch = ''
    substituteAll $setupPath setup.py

    substituteInPlace contrib/matrix_upload.py \
      --replace "env -S " ""
    substituteInPlace contrib/matrix_sso_helper.py \
      --replace "env -S " ""

    substituteInPlace matrix/uploads.py \
      --replace matrix_upload $out/bin/matrix_upload.py
    substituteInPlace matrix/server.py \
      --replace matrix_sso_helper $out/bin/matrix_sso_helper.py
  '' + lib.optionalString (!enableOlm) ''
    substituteInPlace requirements.txt \
      --replace "[e2e]" ""
  '';

  postInstall = ''
    install -D main.py $out/share/weechat/matrix.py
  '';

  meta.broken = python.isPy2;
  passthru = {
    inherit (weechat-matrix) scripts;
  };
}
