{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  nix-update-script,
  setuptools,
  # Dependencies
  tkinter,
}:
buildPythonPackage rec {
  pname = "rcon";
  version = "1.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ttk1";
    repo = "py-rcon";
    tag = "v1.3.0";
    hash = "sha256-IsbGSUXaayO8gfslfo2oIforjy5TW6xVdCDOXT2VmjQ=";
  };
  build-system = [ setuptools ];

  propagatedBuildInputs = [ tkinter ];

  pythonImportsCheck = [ "rcon" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    mainProgram = "rcon-shell";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python implementation of RCON";
    homepage = "https://github.com/ttk1/py-rcon";
    license = with lib.licenses; [ mit ];
  };
}
