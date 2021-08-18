{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, homeassistant
}:

buildPythonPackage rec {
  pname = "homeassistant-stubs";
  version = "2021.8.7";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "KapJI";
    repo = pname;
    rev = "${version}";
    sha256 = "1pkhal4d7y4pxxsg0q7zxhlcfdymm8vghb3pydnsqkw6rg45arwc";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    homeassistant
  ];

  pythonImportsCheck = [ "homeassistant-stubs" ];

  # no tests
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/KapJI/homeassistant-stubs";
    license = licenses.mit;
    description = "PEP 484 typing stubs for Home Assistant Core";
    maintainers = with maintainers; [ graham33 ];
  };
}
