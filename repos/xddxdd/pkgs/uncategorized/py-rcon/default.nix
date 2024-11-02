{
  lib,
  sources,
  python3Packages,
}:
with python3Packages;
buildPythonPackage rec {
  inherit (sources.py-rcon) pname version src;

  propagatedBuildInputs = [ tkinter ];

  meta = {
    mainProgram = "rcon-shell";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python implementation of RCON";
    homepage = "https://github.com/ttk1/py-rcon";
    license = with lib.licenses; [ mit ];
  };
}
