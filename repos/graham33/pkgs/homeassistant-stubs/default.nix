{ lib
, buildPythonPackage
, fetchFromGitHub
, hatch-vcs
, hatchling
, home-assistant
}:

buildPythonPackage rec {
  pname = "homeassistant-stubs";
  version = "2025.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "KapJI";
    repo = pname;
    rev = "${version}";
    sha256 = "1kismhx45d00m7gzv34i6qpbyxvkc30s379jw7vwmdig1ya5rm5v";
  };

  nativeBuildInputs = [
    hatch-vcs
  ];

  build-system = [
    hatchling
  ];

  propagatedBuildInputs = [
    home-assistant
  ];

  pythonImportsCheck = [ "homeassistant-stubs" ];

  meta = with lib; {
    homepage = "https://github.com/KapJI/homeassistant-stubs";
    license = licenses.mit;
    description = "PEP 484 typing stubs for Home Assistant Core";
    maintainers = with maintainers; [ graham33 ];
  };
}
