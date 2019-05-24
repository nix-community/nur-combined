{ python2Packages, mylibs }:
with python2Packages;
buildPythonApplication (mylibs.fetchedGithub ./pg_activity.json // {
  propagatedBuildInputs = [ psycopg2 psutil ];
})
