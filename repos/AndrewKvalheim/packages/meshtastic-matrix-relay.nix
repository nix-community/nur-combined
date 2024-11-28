{ fetchFromGitHub
, lib
, python3Packages
, unstableGitUpdater
}:

let
  inherit (builtins) toFile;
  inherit (lib) replaceStrings;
in
python3Packages.buildPythonApplication rec {
  pname = "meshtastic-matrix-relay";
  version = "0.8.8-unstable-2024-11-23";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "geoffwhittington";
    repo = "meshtastic-matrix-relay";
    rev = "5f20d2411952c8cdb6859df022e5e20adb4f94e7";
    hash = "sha256-qUbXCJoW+HOKT9edeh7lfMFQn6IudS4CP7qx/cl6Uko=";
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
      +version = "${replaceStrings ["-unstable"] ["+unstable"] version}"
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

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Relay between a Matrix room and a Meshtastic radio";
    homepage = "https://github.com/geoffwhittington/meshtastic-matrix-relay";
    license = lib.licenses.mit;
    mainProgram = "meshtastic-matrix-relay";
  };
}
