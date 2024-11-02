{
  lib,
  sources,
  python3Packages,
}:
with python3Packages;
buildPythonPackage rec {
  inherit (sources.smartrent_py) pname version src;

  propagatedBuildInputs = [
    aiohttp
    websockets
  ];

  doCheck = false;

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Api for SmartRent locks, thermostats, moisture sensors and switches";
    homepage = "https://github.com/ZacheryThomas/smartrent.py";
    license = with lib.licenses; [ mit ];
  };
}
