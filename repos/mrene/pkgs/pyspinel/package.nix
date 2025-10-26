{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication {
  pname = "pyspinel";
  version = "1.0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "openthread";
    repo = "pyspinel";
    rev = "5e0627abd04b7d2c7ca47c6615bd14b31227eb4d";
    hash = "sha256-TRZ52xdfXDU23PG/E230JJPt9OKYjQHSX6nrXYAtrsg=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pyserial
  ];

  pythonImportsCheck = [ "spinel" ];

  meta = with lib; {
    description = "Python CLI to configure and manage OpenThread NCPs";
    homepage = "https://github.com/openthread/pyspinel";
    license = licenses.asl20;
    maintainers = with maintainers; [ mrene ];
    mainProgram = "spinel-cli.py";
  };
}
