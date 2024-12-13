{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  bottle,
}:

buildPythonPackage rec {
  pname = "bottle-cors";
  version = "0.1.5";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-cEXMOgLHJ1J8GUfFV5XFvY3yXzonmYOJhWo8XT4vKIo=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace-fail "SNAPSHOT" "${version}"
    echo "bottle" > requirements.txt
  '';

  build-system = [ setuptools ];

  dependencies = [ bottle ];

  meta = with lib; {
    homepage = "https://github.com/truckpad/bottle-cors";
    description = "Simple plugin to easily enable CORS support in Bottle routes";
    license = licenses.unlicense;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
