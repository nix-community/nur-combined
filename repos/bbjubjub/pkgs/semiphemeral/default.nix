{
  lib,
  buildPythonApplication,
  fetchPypi,
  click,
  sqlalchemy,
  tweepy,
  flask,
  colorama,
}:

buildPythonApplication rec {
  pname = "semiphemeral";
  version = "0.5";
  src = fetchPypi {
    inherit pname version;
    sha256 = "0ixshai03idn0zxa8x4rvskd2v7n295wl5jkgs273958clxr2cyn";
  };

  propagatedBuildInputs = [
    click
    sqlalchemy
    tweepy
    flask
    colorama
  ];

  meta = with lib; {
    description = "Automatically delete your old tweets, except for the ones you want to keep";
    longDescription = ''
    There are plenty of tools that let you make your Twitter feed ephemeral,
    automatically deleting tweets older than some threshold, like one month.

    Semiphemeral does this, but also lets you automatically exclude tweets
    based on criteria: how many RTs or likes they have, and if they're part
    of a thread where one of your tweets has that many RTs or likes. It also
    lets you manually select tweets you'd like to exclude from deleting.
    '';

    homepage = https://micahflee.com/2019/06/semiphemeral-automatically-delete-your-old-tweets-except-for-the-ones-you-want-to-keep/;

    license = licenses.mit;
  };
}
