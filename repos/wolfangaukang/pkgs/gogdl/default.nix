{ lib, buildPythonApplication, fetchFromGitHub, requests }:

buildPythonApplication rec {
  pname = "gogdl";
  version = "0.2";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "Heroic-Games-Launcher";
    repo = "heroic-gogdl";
    rev = "v${version}";
    sha256 = "sha256-UdxmDQiAzrcRGiGcqBNf5pus6bvuWID4ZVmFb5ITzhI=";
  };

  propagatedBuildInputs = [
    requests
  ];

  # No tests
  doCheck = false;

  meta = with lib; {
    description = "GOG Downloading module for Heroic Games Launcher";
    homepage = "https://github.com/Heroic-Games-Launcher/heroic-gogdl";
    maintainers = with maintainers; [ wolfangaukang ];
    licenses = licenses.gpl3Only;
  };
}
