{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonPackage rec {
  pname = "spdx";
  version = "2.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bbqsrc";
    repo = "spdx-python";
    rev = "v${version}";
    hash = "sha256-lfTgAX4Wl01xrvLA12ZUqjah7ZiLafMAU+yNNdVkRk0=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [ "spdx" ];

  meta = with lib; {
    description = "SPDX license list database";
    homepage = "https://github.com/bbqsrc/spdx-python";
    license = licenses.cc0;
    maintainers = with maintainers; [ ];
  };
}
