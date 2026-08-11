{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "torrentool";
  version = "1.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "idlesign";
    repo = "torrentool";
    rev = "v${version}";
    hash = "sha256-S7Cp5Qqk7/vaTbqiXfFSz8Kh5MSOYhNse8XRHkNy2Q0=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [ "torrentool" ];

  meta = with lib; {
    description = "The tool to work with torrent files";
    homepage = "https://github.com/idlesign/torrentool";
    changelog = "https://github.com/idlesign/torrentool/blob/${src.rev}/CHANGELOG";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    mainProgram = "torrentool";
  };
}
