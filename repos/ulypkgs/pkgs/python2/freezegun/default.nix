{
  lib,
  buildPythonPackage,
  fetchPypi,
  python-dateutil,
  six,
  mock,
  nose,
  pytest,
}:

buildPythonPackage (finalAttrs: {
  pname = "freezegun";
  version = "0.3.15";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-4gYvLH+VzCdqg0wi8aFxeUZxdrYkzG+TbovDvlU1rRs=";
  };

  propagatedBuildInputs = [
    python-dateutil
    six
  ];
  checkInputs = [
    mock
    nose
    pytest
  ];

  meta = with lib; {
    description = "FreezeGun: Let your Python tests travel through time";
    homepage = "https://github.com/spulec/freezegun";
    license = licenses.asl20;
  };

})
