{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  pytestCheckHook,
  pytest-benchmark,
  enum34,
  numpy,
  arrow,
  ruamel-yaml,
}:

buildPythonPackage (finalAttrs: {
  pname = "construct";
  version = "2.10.54";

  # no tests in PyPI tarball
  src = fetchFromGitHub {
    owner = finalAttrs.pname;
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-iDAxm2Uf1dDA+y+9X/w+PKI36RPK/gDjXnG4Zay+Gtc=";
  };

  checkInputs = [
    pytestCheckHook
    enum34
    numpy
  ];

  # these have dependencies that are broken on Python 2
  disabledTestPaths = [
    "tests/gallery/test_gallery.py"
    "tests/test_benchmarks.py"
    "tests/test_compiler.py"
  ];

  disabledTests = [
    "test_benchmarks"
    "test_timestamp"
  ]
  ++ lib.optionals stdenv.isDarwin [
    "test_multiprocessing"
  ];

  meta = with lib; {
    description = "Powerful declarative parser (and builder) for binary data";
    homepage = "https://construct.readthedocs.org/";
    license = licenses.mit;
    maintainers = with maintainers; [ dotlambda ];
  };
})
