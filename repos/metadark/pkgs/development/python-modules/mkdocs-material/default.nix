{ lib
, buildPythonPackage
, fetchFromGitHub
, markdown
, mkdocs
, mkdocs-material-extensions
, pygments
, pymdown-extensions
}:

buildPythonPackage rec {
  pname = "mkdocs-material";
  version = "6.1.2";

  src = fetchFromGitHub {
    owner = "squidfunk";
    repo = pname;
    rev = version;
    sha256 = "00p4gm59afy1hxv9hl31g5xzfw49cdxmsj54xhr7r5cdf0y6mnpw";
  };

  propagatedBuildInputs = [
    markdown
    mkdocs
    mkdocs-material-extensions
    pygments
    pymdown-extensions
  ];

  # No tests
  doCheck = false;

  meta = with lib; {
    description = "A Material Design theme for MkDocs";
    homepage = "https://squidfunk.github.io/mkdocs-material";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
  };
}
