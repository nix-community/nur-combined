{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "stpl";
  version = "1.13.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rpuntaie";
    repo = "stpl";
    rev = "v${version}";
    hash = "sha256-sO1CYdb2C6cQiM47MdCcmyo+o/RYBlWoOEYYOpJMQw4=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [ "stpl" ];

  meta = with lib; {
    description = "Command line tool that expands a bottle SimpleTemplate file (.stpl";
    homepage = "https://github.com/rpuntaie/stpl";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "stpl";
  };
}
