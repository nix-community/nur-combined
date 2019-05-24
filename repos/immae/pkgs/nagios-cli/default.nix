{ python2Packages, mylibs }:
python2Packages.buildPythonApplication (mylibs.fetchedGithub ./nagios-cli.json)
