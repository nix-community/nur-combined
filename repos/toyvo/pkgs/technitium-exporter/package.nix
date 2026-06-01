{
  lib,
  python3Packages,
  fetchFromGitHub,
  ...
}:

python3Packages.buildPythonApplication rec {
  pname = "technitium-exporter";
  version = "0.1.0";
  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  src = ./.;

  propagatedBuildInputs = with python3Packages; [
    prometheus-client
    requests
    pyyaml
  ];

  meta = {
    description = "Prometheus exporter for Technitium DNS Server";
    homepage = "https://github.com/ToyVo/nixcfg";
    license = lib.licenses.mit;
    mainProgram = "technitium-exporter";
  };
}
