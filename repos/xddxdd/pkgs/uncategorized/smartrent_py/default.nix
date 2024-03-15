{
  lib,
  sources,
  python3Packages,
  ...
}@args:
with python3Packages;
buildPythonPackage rec {
  inherit (sources.smartrent_py) pname version src;

  propagatedBuildInputs = [
    aiohttp
    websockets
  ];

  doCheck = false;

  meta = with lib; {
    description = "Api for SmartRent locks, thermostats, moisture sensors and switches";
    homepage = "https://github.com/ZacheryThomas/smartrent.py";
    license = with licenses; [ mit ];
  };
}
