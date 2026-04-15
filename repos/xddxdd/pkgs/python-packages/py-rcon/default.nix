{
  lib,
  sources,
  buildPythonPackage,
  setuptools,
  # Dependencies
  tkinter,
}:
buildPythonPackage rec {
  inherit (sources.py-rcon) pname version;
  pyproject = true;

  inherit (sources.py-rcon) src;

  build-system = [ setuptools ];

  propagatedBuildInputs = [ tkinter ];

  pythonImportsCheck = [ "rcon" ];

  meta = {
    mainProgram = "rcon-shell";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python implementation of RCON";
    homepage = "https://github.com/ttk1/py-rcon";
    license = with lib.licenses; [ mit ];
  };
}
