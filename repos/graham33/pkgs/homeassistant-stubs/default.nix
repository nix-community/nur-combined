{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, homeassistant
}:

buildPythonPackage rec {
  pname = "homeassistant-stubs";
  version = "2022.10.4";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "KapJI";
    repo = pname;
    rev = "${version}";
    sha256 = "13p49immyhzsg9l9wix55fp51hixjwym0xn8fbkh4frm247zxhqm";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'homeassistant = "2022.4.2"' 'homeassistant = "2022.4.4"'
  '';

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
