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
  version = "6.1.4";

  src = fetchFromGitHub {
    owner = "squidfunk";
    repo = pname;
    rev = version;
    sha256 = "1z6kjm14sa6rb0j1lppvvgxj67lyq7s5h5hc5w6hvg6g8vhws6pi";
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

  meta = with lib; {
    description = "A Material Design theme for MkDocs";
    homepage = "https://squidfunk.github.io/mkdocs-material";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
  };
}
