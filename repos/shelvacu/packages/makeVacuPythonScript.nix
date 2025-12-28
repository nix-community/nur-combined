{
  pyright,
  python3Packages,
  runCommand,
  lib,
  vaculib,
  writers,
  writeText,
}:
# accepts all args that <nixpkgs>/pkgs/development/interpreters/python/mk-python-derivation.nix accepts
# notably including makeWrapperArgs
{
  name,
  src,
  libraries ? [ ],
  doCheck ? true,
}@args:
let
  extraArgs = lib.removeAttrs args [ "libraries" "name" "src" "doCheck" ];
  inherit (python3Packages) hatchling scriptipy buildPythonApplication;
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
  sourceFile = 
    if lib.isDerivation src then
      src
    else if lib.isPath src then
      (vaculib.path src)
    else if lib.isString src then
      writeText "${name}-source-file.py" src
    else
      throw "invalid type for src";
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
        map (p: if lib.isString p then python3Packages.${p} else p) libraries
        ++ [ scriptipy ];

    nativeCheckInputs = [ pyright ];

    inherit doCheck;

    # XXX: This doesn't work(?), python deps don't have a checkPhase (only installCheckPhase)
    checkPhase = ''
      pyright .
    '';

    meta.mainProgram = name;
  }
  // extraArgs
)
