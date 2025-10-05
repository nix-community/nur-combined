{
  lib,
  python310Packages,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}:

python310Packages.buildPythonApplication {
  pname = "modbus_sim_cli";
  version = "0-unstable-2019-02-27";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dhoomakethu";
    repo = "modbus_sim_cli";
    rev = "080d773b7009fa9aa727097d2b2f8049b3f35290";
    hash = "sha256-ijW462q+xhw2I7ZXBhALq3xcSIUi/uEWrva+TCxkKzA=";
  };

  postPatch = ''
    sed -i '/trollius/d' requirements
    substituteInPlace modbus_sim/utils/config_parser.py \
      --replace-fail "yaml.load(conffile.read())" "yaml.safe_load(conffile)"
  '';

  build-system = with python310Packages; [ setuptools ];

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];

  dependencies = with python310Packages; [
    coloredlogs
    modbus-tk
    pyyaml
  ];

  pythonRelaxDeps = true;

  preConfigure = ''
    find modbus_sim -name "*.py" | xargs 2to3 -w
  '';

  meta = {
    description = "Modbus simulation command line version";
    homepage = "https://github.com/dhoomakethu/modbus_sim_cli";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
