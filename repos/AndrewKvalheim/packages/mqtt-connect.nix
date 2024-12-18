{ fetchFromGitHub
, lib
, python3Packages
}:

let
  inherit (builtins) toFile;
in
python3Packages.buildPythonApplication rec {
  pname = "mqtt-connect";
  version = "0.8.7";

  src = fetchFromGitHub {
    owner = "pdxlocations";
    repo = "MQTT-Connect-for-Meshtastic";
    rev = "5a2f636f51710b8879e140d3aa697e7a353ed59b";
    hash = "sha256-F518ErI6ByKozMshiQSN2RVZTEI7+YWGK+cBc32+TDM=";
  };

  patches = [
    (toFile "pep-518.patch" ''
      --- /dev/null
      +++ b/pyproject.toml
      @@ -0,0 +1,16 @@
      +[project]
      +name = "${pname}"
      +version = "${version}"
      +
      +[project.scripts]
      +${meta.mainProgram} = "main:mqtt_connect"
      +
      +[build-system]
      +requires = ["setuptools"]
      +build-backend = "setuptools.build_meta"
      +
      +[tool.setuptools]
      +py-modules = [
      +  "main",
      +  "mqtt-connect",
      +]
      --- /dev/null
      +++ b/main.py
      @@ -0,0 +1,7 @@
      +from pathlib import Path
      +from runpy import run_path
      +
      +
      +def mqtt_connect():
      +    path = Path(__file__).resolve().parent / "mqtt-connect.py"
      +    run_path(path)
    '')

    (toFile "filesystem-paths.patch" ''
      --- a/mqtt-connect.py
      +++ b/mqtt-connect.py
      @@ -87,2 +87,4 @@
      -db_file_path = "mmc.db"
      -presets_file_path = "presets.json"
      +from platformdirs import PlatformDirs
      +dirs = PlatformDirs("mqtt-connect", ensure_exists=True)
      +db_file_path = dirs.user_data_path / "mmc.db"
      +presets_file_path = dirs.user_config_path / "presets.json"
    '')

    (toFile "log-level.patch" ''
      --- a/mqtt-connect.py
      +++ b/mqtt-connect.py
      @@ -43 +43,2 @@
      -debug: bool = False
      +import os
      +debug: bool = os.getenv("DEBUG", "0") == "1"
    '')
  ];

  pyproject = true;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    cryptography
    meshtastic
    paho-mqtt_2
    platformdirs
    tkinter
  ];

  meta = {
    description = "GUI for mocking a Meshtastic node via MQTT";
    homepage = "https://github.com/pdxlocations/MQTT-Connect-for-Meshtastic";
    license = lib.licenses.gpl3;
    mainProgram = "mqtt-connect";
  };
}
