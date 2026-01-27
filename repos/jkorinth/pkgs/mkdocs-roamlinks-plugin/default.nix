{ lib
, python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonPackage rec {
  pname = "mkdocs-roamlinks-plugin";
  version = "0.2.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "JackieXiao";
    repo = "mkdocs-roamlinks-plugin";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-3bj8ysOHb5RzJK2DVvm7MRuXXFIEmJOzfn3VxwHaFv4=";
  };

  propagatedBuildInputs = with python3Packages; [
    mkdocs
  ];

  doCheck = false;

  meta = with lib; {
    description = "An MkDocs plugin that simplifies relative linking between documents and convert [[roamlinks]] for vscode-foam & obsidian";
    homepage = "https://github.com/Jackiexiao/mkdocs-roamlinks-plugin";
    license = licenses.mit;
    maintainers = with maintainers; [ "jkorinth" ];
  };
}
