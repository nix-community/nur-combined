{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, click
, jinja2
, livereload
, lunr
, markdown
, pyyaml
, tornado
, isPy3k
}:

buildPythonPackage rec {
  pname = "mkdocs";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "mkdocs";
    repo = pname;
    rev = version;
    hash = "sha256-d0PH53Fa8o8nY0bYkZR1RkvWN97LAJPaZAlxB7io+dk=";
  };

  patches = [
    ./loosen-requirements.patch
  ];

  propagatedBuildInputs = [
    click
    jinja2
    livereload
    lunr
    markdown
    pyyaml
    tornado
  ];

  pythonImportsCheck = [ "mkdocs" ];

  meta = with lib; {
    description = "Project documentation with Markdown / static website generator";
    longDescription = ''
      MkDocs is a fast, simple and downright gorgeous static site generator that's
      geared towards building project documentation. Documentation source files
      are written in Markdown, and configured with a single YAML configuration file.

      MkDocs can also be used to generate general-purpose Websites.
    '';
    homepage = "https://www.mkdocs.org";
    license = licenses.bsd2;
    maintainers = with maintainers; [ kira-bruneau rkoe ];
    # darwin: AttributeError: partially initialized module 'mkdocs.plugins' has no attribute 'get_plugins' (most likely due to a circular import)
    broken = !isPy3k || stdenv.isDarwin;
  };
}
