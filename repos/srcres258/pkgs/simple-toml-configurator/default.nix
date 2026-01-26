{
  maintainers,
  pkgs,
  ...
}: let
  pythonEnv = pkgs.python312Packages;

  pname = "simple-toml-configurator";
  version = "1.3.0";
in pythonEnv.buildPythonPackage {
  inherit pname version;

  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "GilbN";
    repo = "Simple-TOML-Configurator";
    rev = version;
    sha256 = "sha256-nk5D1/uKezautUAJ4Benj93niiF4FrdUywXI6v6Uxzo=";
  };

  build-system = with pythonEnv; [
    setuptools
  ];

  dependencies = with pythonEnv; [
    tomlkit
    python-dateutil
  ];

  meta = with pkgs.lib; {
    description = "A simple library to read and write TOML configuration files";
    homepage = "https://pypi.org/project/Simple-TOML-Configurator";
    license = licenses.mit;
    maintainers = with maintainers; [ srcres258 ];
  };
}
