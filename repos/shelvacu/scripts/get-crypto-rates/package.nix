{ makeVacuPythonScript }:
makeVacuPythonScript {
  name = "get-crypto-rates";
  libraries = [
    "pydantic"
    "requests"
  ];
  src = ./main.py;
}
