{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "fsindex";
  version = "0-unstable-2026-08-04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "fsindex";
    rev = "1462b11041f854204ab341b13322a95ea51c1cf1";
    hash = "sha256-YM/OIuRTTl+NTfeUNmvk0VfDvj2yrUAukO/px6lXYzs=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    psutil
  ];

  pythonImportsCheck = [
    "fsindex"
  ];

  meta = {
    description = "Filesystem indexer with SQLite storage";
    homepage = "https://github.com/milahu/fsindex";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "fsindex";
  };
})
