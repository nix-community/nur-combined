{
  lib,
  sources,
  python3Packages,
  click-loglevel,
  py-rcon,
  ...
} @ args:
with python3Packages;
  buildPythonApplication rec {
    inherit (sources.palworld-exporter) pname version src;
    pyproject = true;

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
      license = with licenses; [mit];
    };
  }
