{
  lib,
  sources,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  inherit (sources.smartrent_py) pname version src;
  pyproject = true;

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"poetry>=' '"poetry-core>='
  '';

  propagatedBuildInputs = with python3Packages; [
    aiohttp
    poetry-core
    setuptools
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
