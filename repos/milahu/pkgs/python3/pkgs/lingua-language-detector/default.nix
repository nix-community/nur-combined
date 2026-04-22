{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  brotli,
  regex,
}:

buildPythonPackage rec {
  pname = "lingua-language-detector";
  version = "1.4.2";
  pyproject = true;

  src = fetchPypi {
    pname = "lingua_language_detector";
    inherit version;
    hash = "sha256-SHfMSHatXDVpiAkj5A7PKbO69zMIbsgM9TLSXU1BWtU=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    brotli
    regex
  ];

  pythonImportsCheck = [
    # "lingua.LanguageDetectorBuilder" # ModuleNotFoundError
    "lingua"
  ];

  meta = {
    description = "An accurate natural language detection library, suitable for short text and mixed-language text";
    homepage = "https://pypi.org/project/lingua-language-detector/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}
