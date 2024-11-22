{ fetchFromGitHub
, gitUpdater
, lib
, python3Packages
}:

let
  inherit (builtins) toFile;
in
python3Packages.buildPythonApplication rec {
  pname = "meshtastic-matrix-relay";
  version = "0.8.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "geoffwhittington";
    repo = "meshtastic-matrix-relay";
    rev = version;
    hash = "sha256-zNk8dxX5Lnfa1/z9XUGHQ1QvQq+vyeU7NZ2w3E0wAsg=";
  };

  patches = [
    (toFile "config-path.patch" ''
      --- a/config.py
      +++ b/config.py
      @@ -21 +21 @@
      -config_path = os.path.join(get_app_path(), "config.yaml")
      +config_path = os.getenv("CONFIG_PATH")
    '')

    (toFile "pep-518.patch" ''
      --- /dev/null
      +++ b/pyproject.toml
      @@ -0,0 +1,22 @@
      +[project]
      +name = "${pname}"
      +version = "${version}"
      +
      +[project.scripts]
      +${meta.mainProgram} = "main:main_sync"
      +
      +[build-system]
      +requires = ["setuptools"]
      +build-backend = "setuptools.build_meta"
      +
      +[tool.setuptools]
      +packages = ["plugins"]
      +py-modules = [
      +  "config",
      +  "db_utils",
      +  "log_utils",
      +  "main",
      +  "matrix_utils",
      +  "meshtastic_utils",
      +  "plugin_loader",
      +]
      --- a/main.py
      +++ b/main.py
      @@ -148 +148 @@
      -if __name__ == "__main__":
      +def main_sync():
      @@ -152,0 +153,3 @@
      +
      +if __name__ == "__main__":
      +    main_sync()
    '')
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    haversine
    markdown
    matplotlib
    matrix-nio
    meshtastic
    pillow
    py-staticmaps
    requests
    schedule
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Relay between a Matrix room and a Meshtastic radio";
    homepage = "https://github.com/geoffwhittington/meshtastic-matrix-relay";
    license = lib.licenses.mit;
    mainProgram = "meshtastic-matrix-relay";
  };
}
