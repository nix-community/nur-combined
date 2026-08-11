{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonPackage rec {
  pname = "pygubu";
  version = "0.34";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "alejandroautalan";
    repo = "pygubu";
    rev = "v${version}";
    hash = "sha256-hQi3UuRWM0PoF/vhjgXXVh07GJZozY7VX9ujc8dkgdI=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = [
    python3.pkgs.tkinter
  ];

  pythonImportsCheck = [ "pygubu" ];

  meta = with lib; {
    description = "A simple GUI builder for the python tkinter module";
    homepage = "https://github.com/alejandroautalan/pygubu";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
