{
  buildPythonPackage,
  debtcollector,
  fetchFromGitea,
  jsonschema,
  keystoneauth1,
  lib,
  osc-lib,
  oslo-serialization,
  oslo-utils,
  oslotest,
  pbr,
  requests-mock,
  requests,
  setuptools,
  stestr,
}:

buildPythonPackage rec {
  pname = "python-designateclient";
  version = "6.0.1";
  pyproject = true;

  src = fetchFromGitea {
    domain = "opendev.org";
    owner = "openstack";
    repo = "python-designateclient";
    rev = version;
    hash = "sha256-vuaouOA69REx+ZrzXjLGVz5Az1/d6x4WRT1h78xeebk=";
  };

  env.PBR_VERSION = version;

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    debtcollector
    jsonschema
    keystoneauth1
    osc-lib
    oslo-serialization
    oslo-utils
    requests
  ];

  doCheck = true;

  nativeCheckInputs = [
    oslotest
    requests-mock
    stestr
  ];

  checkPhase = ''
    stestr run
  '';

  pythonImportsCheck = [ "designateclient" ];

  meta = {
    homepage = "https://opendev.org/openstack/python-designateclient";
    description = "Client library for OpenStack Designate API";
    license = lib.licenses.asl20;
    maintainers = lib.teams.openstack.members ++ (with lib.maintainers; [ anthonyroussel ]);
  };
}
