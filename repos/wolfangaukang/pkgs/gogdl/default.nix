{ lib, buildPythonApplication, fetchFromGitHub, requests }:

buildPythonApplication rec {
  pname = "gogdl";
  version = "0.3";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "Heroic-Games-Launcher";
    repo = "heroic-gogdl";
    rev = "v${version}";
    sha256 = "sha256-lVNvmdUK7rjSNVdhDuSxyfuEw2FeZt0rVf9pdtsfgqE=";
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
