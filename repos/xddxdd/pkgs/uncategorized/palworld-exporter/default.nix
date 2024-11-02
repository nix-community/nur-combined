{
  lib,
  sources,
  python3Packages,
  click-loglevel,
  py-rcon,
}:
with python3Packages;
buildPythonApplication rec {
  inherit (sources.palworld-exporter) pname version src;
  pyproject = true;

  # Remove dependency on get_version package
  postPatch = ''
    sed -i "/get_version/d" pyproject.toml
    echo "__version__ = '${version}'.removeprefix('v')" > src/palworld_exporter/__init__.py
    sed -i "s/prometheus-client>=0.19,<0.20/prometheus-client/g" pyproject.toml
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

  meta = {
    mainProgram = "palworld_exporter";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Prometheus exporter for Palword Server";
    homepage = "https://github.com/palworldlol/palworld-exporter";
    license = with lib.licenses; [ mit ];
  };
}
