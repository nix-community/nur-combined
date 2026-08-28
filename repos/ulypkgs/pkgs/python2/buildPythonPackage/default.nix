{
  lib,
  buildPythonPackageSuper,
}:

let
  prepare =
    {
      build-system ? [ ],
      dependencies ? [ ],
      optional-dependencies ? { },
      propagatedBuildInputs ? [ ],
      nativeBuildInputs ? [ ],
      passthru ? { },
      pyproject ? false,
      ...
    }@args:
    {
      propagatedBuildInputs = propagatedBuildInputs ++ dependencies;
      nativeBuildInputs = nativeBuildInputs ++ build-system;
      passthru = {
        inherit optional-dependencies;
      }
      // passthru;
    }
    // lib.optionalAttrs pyproject { format = "pyproject"; }
    // removeAttrs args [
      "dependencies"
      "build-system"
      "nativeBuildInputs"
      "optional-dependencies"
      "propagatedBuildInputs"
      "passthru"
      "pyproject"
    ];
in
args:
if lib.isFunction args then
  buildPythonPackageSuper (finalAttrs: prepare (args finalAttrs))
else
  buildPythonPackageSuper (prepare args)
