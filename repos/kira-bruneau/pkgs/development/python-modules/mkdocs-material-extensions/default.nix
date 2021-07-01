{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, markdown
, mkdocs-material
, pytestCheckHook
, isPy3k
}:

buildPythonPackage rec {
  pname = "mkdocs-material-extensions";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "facelessuser";
    repo = pname;
    rev = version;
    hash = "sha256-fnt8Z+DAea6MuWCmrnL0fS2g/KzrkWLwLQL1UXqaNR8=";
  };

  patches = [
    ./mkdocs-material-7.0.0.patch
  ];

  checkInputs = [
    markdown
    mkdocs-material
    pytestCheckHook
  ];

  pythonImportsCheck = [ "materialx" ];

  meta = with lib; {
    description = "Markdown extension resources for MkDocs Material";
    homepage = "https://github.com/facelessuser/mkdocs-material-extensions";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    broken = !isPy3k || stdenv.isDarwin; # mkdocs
  };
}
