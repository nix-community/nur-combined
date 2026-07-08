{
  sources,
  version,
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage {
  inherit (sources) pname src;
  inherit version;

  pyproject = true;
  build-system = with python3Packages; [ setuptools ];

  meta = {
    description = "Find duplicate dependencies in flakes";
    homepage = "https://github.com/Mic92/flake-linter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "flake-linter";
  };
}
