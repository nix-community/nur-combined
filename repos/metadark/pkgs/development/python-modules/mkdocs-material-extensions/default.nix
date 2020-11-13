{ lib
, buildPythonPackage
, fetchFromGitHub
, markdown
, mkdocs-material
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "mkdocs-material-extensions";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "facelessuser";
    repo = pname;
    rev = version;
    sha256 = "07rmk9x53x825pq654gbmkya0bbxyirax9k0p66awyf0w1kpqyvy";
  };

  patches = [
    # See https://github.com/facelessuser/mkdocs-material-extensions/issues/15
    ./fix-tests.patch
  ];

  checkInputs = [
    markdown
    mkdocs-material
    pytestCheckHook
  ];

  meta = with lib; {
    description = "Markdown extension resources for MkDocs Material";
    homepage = "https://github.com/facelessuser/mkdocs-material-extensions";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
  };
}
