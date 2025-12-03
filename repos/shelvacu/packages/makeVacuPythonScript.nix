{
  pyright,
  python3Packages,
  runCommand,
  lib,
  writers,
  writeText,
}:
let
  inherit (python3Packages) hatchling scriptipy buildPythonApplication;
in
name: args: source:
let
  pyproj = {
    project = {
      inherit name;
      version = args.version or "0.0.1";
      scripts.${name} = "run:run";
    };
    build-system = {
      requires = [ "hatchling" ];
      build-backend = "hatchling.build";
    };
    tool.hatch.build.targets.wheel.include = [
      "source.py"
      "run.py"
    ];
  };
  pyproj_toml = writers.writeTOML "${name}-pyproject.toml" pyproj;
  sourceFile = if lib.isPath source then source else writeText "${name}-source-file.py" source;
in
buildPythonApplication (
  {
    pname = name;
    version = "0.0.1";
    pyproject = true;

    src = runCommand "${name}-src" { } ''
      mkdir -p $out
      ln -s ${pyproj_toml} $out/pyproject.toml
      ln -s ${sourceFile} $out/source.py
      printf "def run():\n\timport source" > $out/run.py
    '';

    build-system = [ hatchling ];

    propagatedBuildInputs =
      if lib.isFunction (args.libraries or [ ]) then
        args.libraries python3Packages
      else
        map (p: if lib.isString p then python3Packages.${p} else p) (args.libraries or [ ])
        ++ [ scriptipy ];

    nativeCheckInputs = [ pyright ];

    doCheck = true;

    checkPhase = ''
      pyright .
    '';

    meta.mainProgram = name;
  }
  // (lib.removeAttrs args [ "libraries" ])
)
