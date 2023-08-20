{ lib
, buildPythonPackage
, python3
, fetchFromGitHub
}:

let aalpy =

buildPythonPackage rec {
  pname = "AALpy";
  version = "2022-11-24";
  src = fetchFromGitHub {
    repo = "AALpy";
    owner = "DES-Lab";
    rev = "2465b3e7a63a5af71dbe5011ec87d2a10f66334b";
    sha256 = "sha256-X+Qexz9dkNYhEoa7xYeBWH9JMkIwFgYyhFJIHa7KDqA=";
  };
  propagatedBuildInputs = (with python3.pkgs; [
    pydot
  ]);
  checkPhase = ''
    runHook preCheck
    ${python3.interpreter} -m unittest
    runHook postCheck
  '';
  meta = with lib; {
    homepage = "https://github.com/DES-Lab/AALpy";
    description = "Active Automata Learning";
    license = licenses.mit;
  };
}

; in

aalpy // {
  shell = (python3.withPackages (p: with p; [
    aalpy
  ])).env;
}
