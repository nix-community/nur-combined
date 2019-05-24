{ python3Packages, mylibs }:
with python3Packages;
buildPythonApplication (mylibs.fetchedGithub ./mutt-ics.json // {
  propagatedBuildInputs = [ icalendar ];
})
