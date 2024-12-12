{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "apibackuper";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "ruarxive";
    repo = "apibackuper";
    tag = version;
    hash = "sha256-2vNuzQK6Wm6DBWRSLFuy6loCLAbcql3CqSktMjGE8JE=";
  };

  dependencies = with python3Packages; [
    bson
    click
    lxml
    requests
    xmltodict
  ];

  doCheck = false;

  meta = {
    description = "Python library and cmd tool to backup API calls";
    homepage = "https://github.com/ruarxive/apibackuper";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
