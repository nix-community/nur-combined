{ lib
, python
, buildPythonPackage
, fetchFromGitHub
# , check-shapes
, tensorflow
, tensorflow-probability
, numpy
, scipy
, deprecated
, lark
, multipledispatch
, typing-extensions
, tabulate
, keras
, packaging
, pytestCheckHook
, gpflow
}:
buildPythonPackage rec {
  pname = "GPflow";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "GPflow";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-mt1Ozu+Mbn6XCF9eFj5SNue/kqWbO71z81tpNSZqREo=";
  };
  postPatch = ''
    sed -i '/tensorflow>=/d' setup.py
  '';

  buildInputs = [
    tensorflow
    tensorflow-probability
  ];
  propagatedBuildInputs = [
    # check-shapes
    keras
    numpy
    scipy
    deprecated
    lark
    multipledispatch
    packaging
    typing-extensions
    tabulate
  ];

  disabledTests = [
    "test_ImageToTensorBoard"
    "test_print_summary_for_keras_model"
  ];
  disabledTestPaths = [
    "tests/integration/test_notebooks.py"
  ];
  checkInputs = [
    pytestCheckHook
  ];
  pythonImportsCheck = [ "gpflow" ];

  doCheck = false;
  passthru.tests.check = gpflow.overridePythonAttrs (_: { doCheck = true; });

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.asl20;
    description = "Gaussian processes in TensorFlow";
    homepage = "https://www.gpflow.org/";
    platforms = lib.platforms.unix;
    broken = true; # check-shape, overpins, etc
  };
}
