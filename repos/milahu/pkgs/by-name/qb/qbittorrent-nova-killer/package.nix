{
  lib,
  python3,
  fetchFromGitHub,
  psutil,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "qbittorrent-nova-killer";
  version = "unstable-2025-09-11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "qbittorrent-nova-killer";
    rev = "91d78c930041d8bdf80a7e86a4e604b8429bddda";
    hash = "sha256-lO9A3GwXNe8la+3at8oXj7xOw6QPSmtCKBFMp4GzMU4=";
  };

  dependencies = [
    psutil
  ];

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [
    "qbittorrent_nova_killer"
  ];

  meta = {
    description = "Utility to kill runaway qBittorrent nova2.py processes";
    homepage = "https://github.com/milahu/qbittorrent-nova-killer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "qbittorrent-nova-killer";
  };
}
