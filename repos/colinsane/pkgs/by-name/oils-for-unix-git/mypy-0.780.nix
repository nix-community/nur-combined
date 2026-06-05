{
  lib,
  fetchFromGitHub,
  python3,
  # Injected dependencies
  mypy-extensions,
  typed-ast,
}:

# mypy 0.780 is the last version with --py2 support
# Built without mypyc so mycpp can extend its classes
python3.pkgs.buildPythonPackage (finalAttrs: {
  pname = "mypy";
  version = "0.780";

  pyproject = true;
  build-system = [ python3.pkgs.setuptools ];

  src = fetchFromGitHub {
    owner = "python";
    repo = "mypy";
    rev = "v${finalAttrs.version}";
    # Fetch submodules to include typeshed (required for type stubs)
    fetchSubmodules = true;
    hash = "sha256-czwCx6ZjCu3CrVmbI6NbstzWM0GvuPTWJiiUhXSznu4=";
  };

  # Do not use mypyc to compile.
  # Rather, build interpreted so mycpp can extend its classes.
  preBuild = ''
    export MYPY_USE_MYPYC=0
  '';

  # Skip tests to speed up build
  doCheck = false;

  # Skip runtime dependency check since we're using pinned older versions
  pythonRuntimeDepsCheck = false;
  dontCheckRuntimeDeps = true;

  dependencies = [
    mypy-extensions
    typed-ast
    python3.pkgs.typing-extensions
  ];

  # Ensure we're not pulling in a compiled version
  pythonImportsCheck = [ "mypy" ];

  meta.license = lib.licenses.mit;
})
