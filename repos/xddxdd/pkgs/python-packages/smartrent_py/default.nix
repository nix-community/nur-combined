{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  aiohttp,
  poetry-core,
  setuptools,
  websockets,
}:
buildPythonPackage rec {
  inherit (sources.smartrent_py) pname version src;
  pyproject = true;

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"poetry>=' '"poetry-core>='
  '';

  propagatedBuildInputs = [
    aiohttp
    poetry-core
    setuptools
    websockets
  ];

  pythonImportsCheck = [ "smartrent" ];

  # Upstream dependency restriction is too strict
  dontCheckRuntimeDeps = true;

  meta = {
    changelog = "https://github.com/zacherythomas/smartrent-py/releases/tag/v${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Api for SmartRent locks, thermostats, moisture sensors and switches";
    homepage = "https://github.com/ZacheryThomas/smartrent.py";
    license = with lib.licenses; [ mit ];
  };
}
