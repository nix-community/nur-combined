{ lib
, buildPythonPackage
, fetchFromGitHub
, markdown
, mkdocs
, pygments
, pymdown-extensions
, mkdocs-material-extensions
}:

buildPythonPackage rec {
  pname = "mkdocs-material";
  version = "7.0.7";

  src = fetchFromGitHub {
    owner = "squidfunk";
    repo = pname;
    rev = version;
    hash = "sha256-LzTLOLskJmjezQ+1PtoinacxgjpcCWuNYhd0hKFiK+U=";
  };

  patches = lib.optional (mkdocs-material-extensions == null)
    ./remove-circular-dependency.patch;

  propagatedBuildInputs = [
    markdown
    mkdocs
    pygments
    pymdown-extensions
  ] ++ lib.optional (mkdocs-material-extensions != null) mkdocs-material-extensions;

  # No tests
  doCheck = false;

  # Strip adds unnecessary overhead with no binary files to strip
  dontStrip = true;

  meta = with lib; {
    description = "A Material Design theme for MkDocs";
    homepage = "https://squidfunk.github.io/mkdocs-material";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
  };
}
