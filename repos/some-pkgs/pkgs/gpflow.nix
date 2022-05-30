{ lib
, python
, buildPythonPackage
, fetchFromGitHub
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
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "GPflow";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-0ga8GcW5YZ26WQrHslYPBEmTm/J6OZcc6nKG4F2FCTs=";
  };
  postPatch = ''
    sed -i '/tensorflow>=/d' setup.py
  '';

  buildInputs = [
    tensorflow
    tensorflow-probability
  ];
  propagatedBuildInputs = [
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
  };
}
