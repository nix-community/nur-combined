{
  lib,
  fetchFromGitea,
  python3Packages,
  pyramid-debugtoolbar,
  pyramid-retry,
  pyramid-tm,
  zope-sqlalchemy,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "fietsboek";
  version = "0.12.1";
  pyproject = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "dunj3";
    repo = "fietsboek";
    tag = "v${finalAttrs.version}";
    hash = "sha256-48ORARprpXN+2JJku+QMz0mLNZT0iWzvMXwFRylsUjU=";
  };

  build-system = with python3Packages; [ poetry-core ];

  pythonRelaxDeps = true;

  dependencies = with python3Packages; [
    pyramid
    pyramid-jinja2
    pyramid-debugtoolbar
    pyramid-retry
    pyramid-tm
    waitress
    sqlalchemy
    alembic
    transaction
    zope-sqlalchemy
    redis
    babel
    cryptography
    gpxpy
    markdown
    nh3
    click
    requests
    pydantic
    termcolor
    filelock
    brotli
    click-option-group
    fitparse
    pillow
    typst
    matplotlib
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-cov-stub
    pytest-playwright
    webtest
  ];

  doCheck= false;

  meta = {
    description = "GPX file sharing website";
    homepage = "https://fietsboek.org/";
    license = lib.licenses.agpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
