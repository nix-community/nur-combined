{ lib
, buildPythonPackage
, fetchFromGitHub
, hatch-vcs
, hatchling
, home-assistant
}:

buildPythonPackage rec {
  pname = "homeassistant-stubs";
  version = "2025.2.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "KapJI";
    repo = pname;
    rev = "${version}";
    sha256 = "19hv92asf7pqb2fb1w3w5ysc86jlvz59fdrg22pp5xhfn82wrsim";
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
