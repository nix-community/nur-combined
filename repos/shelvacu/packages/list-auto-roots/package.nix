{ makeVacuPythonScript }:
makeVacuPythonScript {
  name = "list-auto-roots";
  libraries = [ "scriptipy" ];
  src = ./main.py;
}
