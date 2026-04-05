{
  lib,
  buildPythonPackageSuper,
}:

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
buildPythonPackageSuper (
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
  ]
)
