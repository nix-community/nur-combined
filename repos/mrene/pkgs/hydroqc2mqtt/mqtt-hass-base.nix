{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, setuptools-scm
, wheel
, aiomqtt
, homeassistant
, pythonRelaxDepsHook
}:

buildPythonPackage rec {
  pname = "mqtt-hass-base";
  version = "4.3.0";
  pyproject = true;

  src = fetchPypi {
    pname = "mqtt_hass_base";
    inherit version;
    hash = "sha256-ryTkNhyR4yzlw+XvN/zTPNUgtaHXc+RkjmNC8K8FEEk=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail "setuptools==69.5.1" "setuptools"
    substituteInPlace pyproject.toml --replace-fail "setuptools_scm[toml]==8.1.0" "setuptools_scm[toml]"
    substituteInPlace pyproject.toml --replace-fail "wheel==0.43.0" "wheel"

    sed -i 's/setuptools[~=]/setuptools>/' pyproject.toml
    sed -i 's/wheel[~=]/wheel>/' pyproject.toml
    '';

  doCheck = false;

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    wheel
    pythonRelaxDepsHook
  ];

  pythonRelaxDeps = true; 

  propagatedBuildInputs = [
    aiomqtt
    homeassistant
  ];

  pythonImportsCheck = [ "mqtt_hass_base" ];

  meta = with lib; {
    description = "Bases to build mqtt daemon compatible with Home Assistant";
    homepage = "https://pypi.org/project/mqtt-hass-base/";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
