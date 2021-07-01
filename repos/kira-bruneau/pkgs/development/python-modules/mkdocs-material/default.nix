{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, markdown
, mkdocs
, pygments
, pymdown-extensions
, mkdocs-material-extensions
, isPy3k
}:

buildPythonPackage rec {
  pname = "mkdocs-material";
  version = "7.1.4";

  src = fetchFromGitHub {
    owner = "squidfunk";
    repo = pname;
    rev = version;
    hash = "sha256-c8uRjWgHd+SkYPxavUkKDtYm4UfvsJgoLsfn8duu+54=";
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
  pythonImportsCheck = [ "material" ];

  # Strip adds unnecessary overhead with no binary files to strip
  dontStrip = true;

  meta = with lib; {
    description = "A Material Design theme for MkDocs";
    homepage = "https://squidfunk.github.io/mkdocs-material";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    broken = !isPy3k || stdenv.isDarwin; # mkdocs
  };
}
