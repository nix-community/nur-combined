{
  lib,
  sources,
  python3Packages,
  ...
}@args:
with python3Packages;
buildPythonPackage rec {
  inherit (sources.py-rcon) pname version src;

  propagatedBuildInputs = [ tkinter ];

  meta = with lib; {
    description = "Python implementation of RCON";
    homepage = "https://github.com/ttk1/py-rcon";
    license = with licenses; [ mit ];
  };
}
