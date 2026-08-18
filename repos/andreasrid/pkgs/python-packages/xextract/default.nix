{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  lxml,
  cssselect,
}:

buildPythonPackage {
  pname = "xextract";
  version = "0.1.8";
  pyproject = true;
  src = fetchFromGitHub {
    owner = "Mimino666";
    repo = "python-xextract";
    rev = "08b9c326b6433ee931bb7703e2acf27ffc317029";
    hash = "sha256-KAyDNSrbIFb+KYy15sdBM2xt6oa3xH85zfrjwtzR0vY=";
  };

  propagatedBuildInputs = [
    setuptools
    lxml
    cssselect
  ];
}
