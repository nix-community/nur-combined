{
  lib,
  python3Packages,
  ...
}:

python3Packages.buildPythonApplication rec {
  pname = "network-inventory";
  version = "0.1.0";
  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  src = ./.;

  propagatedBuildInputs = with python3Packages; [
    prometheus-client
    requests
  ];

  meta = {
    description = "Network device inventory collector for Prometheus";
    homepage = "https://github.com/ToyVo/nixcfg";
    license = lib.licenses.mit;
    mainProgram = "network-inventory";
  };
}
