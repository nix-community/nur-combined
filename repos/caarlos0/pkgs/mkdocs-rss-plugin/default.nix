{ lib
, python3
, fetchPypi
}:

python3.pkgs.buildPythonPackage rec {
  pname = "mkdocs-rss-plugin";
  version = "1.12.1";
  format = "wheel";

  src = fetchPypi rec {
    inherit version format;
    pname = "mkdocs_rss_plugin";
    hash = "sha256-rPuO7JXx2zibNncLr5mvO4fjhITMN5kxlKNaoXPrP+g=";
    dist = python;
    python = "py2.py3";
  };

  meta = with lib; {
    description = "MkDocs plugin to generate a RSS feeds for created and updated pages, using git log and YAML frontmatter (page.meta).";
    homepage = "https://github.com/Guts/mkdocs-rss-plugin";
    license = licenses.mit;
    maintainers = with maintainers; [ caarlos0 ];
  };
}
