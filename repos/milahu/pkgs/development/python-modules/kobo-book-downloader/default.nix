# TODO fix login via GUI
# https://github.com/subdavis/kobo-book-downloader/issues/172
# workaround: remove the GUI user and login via CLI
/*
kobodl user list
kobodl user rm xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
kobodl user add
kobodl book list
kobodl book get xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
*/

{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "kobo-book-downloader";
  version = "0.14.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "subdavis";
    repo = "kobo-book-downloader";
    tag = finalAttrs.version;
    hash = "sha256-z1q5kqcyJFbmRzQQyAIjDk3lBholwcKsbrsss5eOumQ=";
  };

  postPatch = ''
    # remove dataclasses dependency
    # unpin dependencies
    sed -i -E '
      /^dataclasses /d;
      s/(dataclasses-json|flask|setuptools|tabulate) = ".*"/\1 = "*"/;
    ' pyproject.toml
  '';

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
    beautifulsoup4
    click
    # dataclasses # backport for Python 3.6
    dataclasses-json
    flask
    pycryptodome
    requests
    setuptools
    tabulate
  ];

  pythonImportsCheck = [
    "kobodl"
  ];

  meta = {
    description = "A tool to download and remove DRM from your purchased Kobo.com ebooks and audiobooks";
    homepage = "https://github.com/subdavis/kobo-book-downloader";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "kobodl";
  };
})
