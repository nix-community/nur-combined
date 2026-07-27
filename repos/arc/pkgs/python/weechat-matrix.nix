{ lib, pythonPackages, weechat-matrix, fetchFromGitHub, fetchpatch, enableOlm ? true }: let

  jsonschema = (pythonPackages.jsonschema.override {
    rpds-py = null;
  }).overrideAttrs (old: rec {
    name = "${old.pname}-${version}";
    version = "4.17.3";
    src = pythonPackages.jsonschema.src.override {
      inherit version;
      hash = "sha256-D4ZEN6uLYHa6ZwdFPvj5imoNUSqA6T+KvbZ29zfstg0=";
    };
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      pythonPackages.pyrsistent
    ];
  });
  matrix-nio = (pythonPackages.matrix-nio.override {
    inherit jsonschema;
    #${if enableOlm then "withOlm" else null} = true;
  }).overrideAttrs (old: {
    doInstallCheck = false;
  });
in with pythonPackages; buildPythonPackage rec {
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
    pyrsistent # why isn't this propagated from jsonschema via nio? .-.
    pyopenssl
    webcolors
    atomicwrites
    attrs
    pythonPackages.logbook or pythonPackages.Logbook
    pygments
    requests
    pythonPackages.python-magic or pythonPackages.python_magic
    matrix-nio
  ] ++ lib.optional (pythonOlder "3.5") typing
  ++ lib.optional (pythonOlder "3.2") future
  ++ lib.optional (pythonAtLeast "3.5") aiohttp
  ++ lib.optionals enableOlm (matrix-nio.optional-dependencies.e2e or [
    cachetools
    python-olm
    peewee
  ]);

  patches = [
    (fetchpatch {
      # python-future is gone on 3.13
      # https://github.com/poljar/weechat-matrix/pull/368
      url = "https://github.com/poljar/weechat-matrix/pull/368.patch";
      name = "python-future";
      hash = "sha256-BhOfHfNV9GtCcKTGUy+7ByqJcDxBW/YubHQpHOnVv7Q=";
    })
    # conflicts with above patch .-.
    /*(fetchpatch {
      # fixes ImportError: PyO3 modules do not yet support subinterpreters
      # https://github.com/poljar/weechat-matrix/pull/367
      url = "https://github.com/poljar/weechat-matrix/pull/367.patch";
      name = "pyopenssl-pyo3";
      hash = "sha256-pPh/M+BMq5X7WWmUI4fPxyhBn1FNqliQ4VhHSCybD3U=";
    })*/
    ./pyopenssl-pyo3.patch
  ];

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
    inherit matrix-nio;
  };
}
