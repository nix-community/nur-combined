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
  pathPkgs ? [ ],
  doCheck ? true,
  data ? null,
  dataTypeOverrides ? { },
  typeCheckingMode ? "strict",
  ...
}@args:
let
  extraArgs = lib.removeAttrs args [
    "name"
    "src"
    "libraries"
    "doCheck"
    "data"
    "dataTypeOverrides"
    "typeCheckingMode"
  ];
  inherit (python3Packages) hatchling scriptipy buildPythonApplication;
  moduleName =
    assert (builtins.match "[a-zA-Z_-][a-zA-Z0-9_-]*" name) != null;
    lib.replaceStrings [ "-" ] [ "_" ] name;
  hasData = data != null;
  pyproj = {
    project = {
      inherit name;
      version = args.version or "0.0.1";
      scripts.${name} = "${moduleName}:run";
    };
    build-system = {
      requires = [ "hatchling" ];
      build-backend = "hatchling.build";
    };
    tool.hatch.build.targets.wheel.include = [ moduleName ];
    tool.pyright = {
      inherit typeCheckingMode;
      reportWildcardImportFromLibrary = false;
    };
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
  pythonTypeOf =
    x:
    if vaculib.isStringish x then
      "str"
    else if builtins.isBool x then
      "bool"
    else if builtins.isInt x then
      "int"
    else if builtins.isList x then
      (
        if x == [ ] then
          "list[Never]"
        else
          lib.pipe x [
            (map (el: pythonTypeOf el))
            lib.lists.uniqueStrings
            (lib.concatStringsSep "|")
            (x: "list[${x}]")
          ]
      )
    else if builtins.isAttrs x then
      (
        if x == { } then
          "dict[str, Never]"
        else
          lib.pipe x [
            builtins.attrValues
            (map (el: pythonTypeOf el))
            lib.lists.uniqueStrings
            (lib.concatStringsSep "|")
            (x: "dict[str, ${x}]")
          ]
      )
    else
      throw "pythonTypeOf: dunno how to handle ${builtins.typeOf x}";
  escapePythonStr =
    s:
    lib.pipe s [
      toString
      (lib.replaceStrings [ ''\'' ''"'' "\r" "\n" "\t" ] [ ''\\'' ''\"'' ''\r'' ''\n'' ''\t'' ])
      (s: ''"${s}"'')
    ];
  toPythonExpr =
    x:
    if vaculib.isStringish x then
      escapePythonStr x
    else if builtins.isBool x then
      (if x then "True" else "False")
    else if builtins.isInt x then
      toString x
    else if builtins.isList x then
      lib.pipe x [
        (map toPythonExpr)
        (lib.concatStringsSep ", ")
        (x: "[${x}]")
      ]
    else if builtins.isAttrs x then
      lib.pipe x [
        (lib.mapAttrsToList (k: v: "${escapePythonStr k}: ${toPythonExpr v}"))
        (lib.concatStringsSep ", ")
        (x: "{${x}}")
      ]
    else
      throw "toPythonExpr: dunno how to handle ${builtins.typeOf x}";
  dataMainText = lib.pipe data [
    (lib.mapAttrsToList (
      k: v:
      let
        ty = dataTypeOverrides.${k} or (pythonTypeOf v);
      in
      "${k}:${ty} = ${toPythonExpr v}"
    ))
    (map (x: x + "\n\n"))
    lib.concatStrings
  ];
  dataImportText = "from typing import Any, Never";
  dataText = dataImportText + "\n\n" + dataMainText;
  dataFile = writeText "${name}-nixdata.py" dataText;

  nixdataPkg = python3Packages.toPythonModule (runCommand "nixdata-for-${name}" {
    nativeBuildInputs = [ python3Packages.python ];
  } ''
    declare outDir="$out/"${lib.escapeShellArg python3Packages.python.sitePackages}"/nixdata"
    mkdir -p "$outDir"
    cp -T -- ${dataFile} "$outDir/__init__.py"
    touch "$outDir/py.typed"
    python -m compileall -q --invalidation-mode unchecked-hash "$outDir"
  '');

  initFile = writeText "makeVacuPythonScript-init.py" ''
    def run():
      from . import vacuPythonScript__source # pyright: ignore[reportUnusedImport]
  '';
in
buildPythonApplication (
  extraArgs
  // {
    pname = name;
    version = "0.0.1";
    pyproject = true;

    src = runCommand "${name}-src" { } ''
      declare moduleDir="$out/"${lib.escapeShellArg moduleName}
      mkdir -p "$moduleDir"
      cp -T ${pyproj_toml} $out/pyproject.toml
      cp -T ${sourceFile} "$moduleDir/vacuPythonScript__source.py"
      cp -T ${initFile} "$moduleDir/__init__.py"
    '';

    build-system = [ hatchling ];

    propagatedBuildInputs =
      (
        if lib.isFunction (args.libraries or [ ]) then
          args.libraries python3Packages
        else
          map (p: if lib.isString p then python3Packages.${p} else p) libraries ++ [ scriptipy ]
      )
      ++ (lib.optional hasData nixdataPkg)
      ++ (extraArgs.propogatedBuildInputs or [ ]);

    nativeCheckInputs = [ pyright ] ++ (extraArgs.nativeCheckInputs or [ ]);

    inherit doCheck;

    # XXX: This doesn't work(?), python deps don't have a checkPhase (only installCheckPhase)
    checkPhase = ''
      pyright .
    '';

    makeWrapperArgs =
      [ ]
      ++ (lib.optionals (pathPkgs != [ ]) [
        "--prefix"
        "PATH"
        ":"
        (lib.makeBinPath pathPkgs)
      ])
      ++ extraArgs.makeWrapperArgs or [ ];

    meta = {
      mainProgram = name;
    }
    // (extraArgs.meta or { });

    passthru = {
      isVacuPythonScript = true;
      srcFile = src;
      inherit hasData;
    }
    // (lib.optionalAttrs hasData { inherit dataFile dataText; })
    // (extraArgs.passthru or { });
  }
)
