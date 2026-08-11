{
  lib,
  python,
  fetchFromGitHub,
}:

python.pkgs.buildPythonApplication rec {
  pname = "repro-zipfile";
  version = "0.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "drivendataorg";
    repo = "repro-zipfile";
    rev = "cli-v${version}";
    hash = "sha256-HMRwwNVNifk6slmOEE4cHcNuf9BR0cgrwMlU9KHneVY=";
  };

  build-system = [
    python.pkgs.hatchling
  ];

  pythonImportsCheck = [
    "repro_zipfile"
  ];

  meta = {
    description = "A tiny, zero-dependency replacement for Python's zipfile.ZipFile for creating reproducible/deterministic ZIP archives";
    homepage = "https://github.com/drivendataorg/repro-zipfile";
    changelog = "https://github.com/drivendataorg/repro-zipfile/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "repro-zipfile";
  };
}
