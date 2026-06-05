{
  lib,
  fetchFromGitHub,
  python3,
}:

# mypy 0.780 requires mypy-extensions <0.5.0
python3.pkgs.buildPythonPackage (finalAttrs: {
  pname = "mypy-extensions";
  version = "0.4.4";
  pyproject = true;
  build-system = [ python3.pkgs.setuptools ];

  src = fetchFromGitHub {
    owner = "python";
    repo = "mypy_extensions";
    rev = finalAttrs.version;
    hash = "sha256-eZdEJJA6HOf1iQLV9H9qqETEByCgIH6oy+wwffGJVuQ=";
  };

  pythonImportsCheck = [ "mypy_extensions" ];
  meta.license = lib.licenses.mit;
})
