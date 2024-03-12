{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonPackage {
  pname = "mkdocs-rss-plugin";
  version = "1.12.1";

  src = fetchFromGitHub {
    owner = "Guts";
    repo = "mkdocs-rss-plugin";
    rev = "1.12.1";
    sha256 = "sha256-cLQfhMYW/9Eb+IamQIC7fZRTm/ORD8xbcrmKkSkUrMs=";
  };


  nativeBuildInputs = [ python3.pkgs.mkdocs ];
  doCheck = false;

  meta = with lib; {
    description = "MkDocs plugin to generate a RSS feeds for created and updated pages, using git log and YAML frontmatter (page.meta).";
    homepage = "https://github.com/Guts/mkdocs-rss-plugin";
    license = licenses.mit;
    maintainers = with maintainers; [ caarlos0 ];
  };
}
