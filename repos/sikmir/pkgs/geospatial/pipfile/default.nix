{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "pipfile";
  version = "0.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pypa";
    repo = "pipfile";
    tag = "v${version}";
    hash = "sha256-GsDhxnvBvjJGQWk25cS9+HqLQ9YVSxujeX2iGivYl6Q=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ toml ];

  doCheck = false;
  pythonImportsCheck = [ "pipfile" ];

  meta = {
    description = "Pipfile: the replacement for requirements.txt";
    homepage = "https://github.com/pypa/pipfile";
    license = with lib.licenses; [
      asl20
      bsd2
    ];
    maintainers = [ lib.maintainers.sikmir ];
  };
}
