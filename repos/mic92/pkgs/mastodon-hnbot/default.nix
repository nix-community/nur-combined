{ lib, stdenv, fetchFromGitHub, buildPythonApplication, feedparser, mastodon-py }:

buildPythonApplication rec {
  pname = "mastodon-hnbot";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "mastodon-hnbot";
    rev = version;
    sha256 = "1mwrl5gspk9icn0jvsy6dj09dsqgi1nzai9ls6as6kyaz9bm40ff";
  };
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
