{ lib, pythonPackages, weechat-matrix, fetchFromGitHub, enableOlm ? true }:

with pythonPackages; let

  matrix-nio-0_21 = (pythonPackages.matrix-nio.override {
    logbook = null;
  }).overridePythonAttrs (old: rec {
    version = "0.21.2";
    src = fetchFromGitHub {
      owner = "poljar";
      repo = "matrix-nio";
      rev = version;
      sha256 = "sha256-eK5DPmPZ/hv3i3lzoIuS9sJXKpUNhmBv4+Nw2u/RZi0=";
    };
  });
  matrix-nio = if lib.versionOlder pythonPackages.matrix-nio.version "0.21"
    then matrix-nio-0_21
    else pythonPackages.matrix-nio.overridePythonAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [
        pythonRelaxDepsHook
      ];
      pythonRelaxDeps = [
        "cachetools"
      ];
    });

in buildPythonPackage rec {
  pname = "weechat-matrix";
  version = "2023.07.23";
  src = fetchFromGitHub {
    owner = "poljar";
    repo = pname;
    rev = "feae9fda26ea9de98da9cd6733980a203115537e";
    sha256 = "sha256-flv1XF0tZgu3qoMFfJZ2MzeHYI++t12nkq3jJkRiCQ0=";
  };
  format = "setuptools";

  nativeBuildInputs = [
    pip
  ];
  propagatedBuildInputs = [
    pyopenssl
    webcolors
    atomicwrites
    attrs
    pythonPackages.logbook or pythonPackages.Logbook
    pygments
    requests
    python_magic
    matrix-nio
  ] ++ lib.optional (pythonOlder "3.5") typing
  ++ lib.optional (pythonOlder "3.2") future
  ++ lib.optional (pythonAtLeast "3.5") aiohttp
  ++ lib.optionals enableOlm (matrix-nio.optional-dependencies.e2e or [
    cachetools
    python-olm
    peewee
  ]);

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
