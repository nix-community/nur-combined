{
  python3Packages,
  fetchFromGitHub,
  lib,
}:
python3Packages.buildPythonPackage{
  pname = "circular-import-detector";
  version = "2025-10-17";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "PalNilsson";
    repo = "circular-import-detector";
    rev = "8a10f004b0964d04357902c335f55ed25da44efa";
    hash = "sha256-xNgOjzkXoWj7v9RCZDrlRr0TyZh4RknheqUgZGllR8M=";
  };

  build-system = with python3Packages; [ setuptools ];

  meta = {
    description = "A tool to detect circular imports in Python projects";
    homepage = "https://github.com/PalNilsson/circular-import-detector";
    license = lib.licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
  };
}
