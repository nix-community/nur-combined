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
  version = "7.2.1";

  src = fetchFromGitHub {
    owner = "squidfunk";
    repo = pname;
    rev = version;
    sha256 = "sha256-ROYCGhZV3mwtkdxwjbN8Kj/zIO22vJhprLwTO7w1xKg=";
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
