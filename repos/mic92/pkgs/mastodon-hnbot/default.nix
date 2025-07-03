{ lib, fetchFromGitHub, buildPythonApplication, feedparser, mastodon-py, setuptools }:

buildPythonApplication rec {
  pname = "mastodon-hnbot";
  version = "1.0.1";
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "mastodon-hnbot";
    rev = version;
    sha256 = "1zh624h8q8jm9v3fb7dn6sn7gn6iki79rpgj5spxi8jcqqjyk9vj";
  };
  pyproject = true;
  build-system = [ setuptools ];
  propagatedBuildInputs = [
    feedparser
    mastodon-py
  ];
  meta = with lib; {
    description = "A bot posting hnbot news";
    homepage = "https://github.com/Mic92/mastodon-hnbot";
    license = licenses.mit;
  };
}
