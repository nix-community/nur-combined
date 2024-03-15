{
  lib,
  sources,
  python3Packages,
  click-loglevel,
  py-rcon,
  ...
}@args:
with python3Packages;
buildPythonApplication rec {
  inherit (sources.palworld-exporter) pname version src;
  pyproject = true;

  # Remove dependency on get_version package
  postPatch = ''
    sed -i "/get_version/d" pyproject.toml
    echo "__version__ = '${version}'.removeprefix('v')" > src/palworld_exporter/__init__.py
  '';

  propagatedBuildInputs = [
    setuptools
    click
    click-loglevel
    prometheus-client
    py-rcon
    requests
  ];

  doCheck = false;

  meta = with lib; {
    description = "Prometheus exporter for Palword Server";
    homepage = "https://github.com/palworldlol/palworld-exporter";
    license = with licenses; [ mit ];
  };
}
