{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pytestCheckHook,
  cached-property,
}:

buildPythonPackage rec {
  pname = "charset-normalizer";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "Ousret";
    repo = "charset_normalizer";
    tag = version;
    hash = "sha256-4suRZrt4wfoxYSx92tv8pF5+JRwBfV/aqnchyRF+dNA=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace-fail "REQUIRES_PYTHON = '>=3.5.0'" "REQUIRES_PYTHON = '>=2.7.0'"
    substituteInPlace setup.py --replace-fail "✅" ""
  '';

  dependencies = [ cached-property ];

  checkInputs = [
    pytestCheckHook
  ];

  disabledTests = [
    "test_class_method_subclass_spy"
    "test_static_method_subclass_spy"
  ];

  pythonImportsCheck = [ "charset_normalizer" ];

  meta = with lib; {
    description = "Python module for encoding and language detection";
    homepage = "https://charset-normalizer.readthedocs.io/";
    license = licenses.mit;
    maintainers = with maintainers; [ fab ];
  };
}
