{ lib
, buildPythonPackage
, fetchFromGitHub
, hatch-vcs
, hatchling
, home-assistant
}:

buildPythonPackage rec {
  pname = "homeassistant-stubs";
  version = "2024.10.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "KapJI";
    repo = pname;
    rev = "${version}";
    sha256 = "0ddgy8fin27f91y8m7wiysz8mfjwb77ly0k1dzfkqc9kag3jj961";
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
