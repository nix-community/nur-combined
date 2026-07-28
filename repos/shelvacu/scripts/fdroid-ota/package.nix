{
  fetchFromGitLab,
  makeVacuPythonScript,
  zip,
}:
makeVacuPythonScript {
  name = "fdroid-ota";
  src = ./script.py;
  data.privileged_src = fetchFromGitLab {
    owner = "fdroid";
    repo = "privileged-extension";
    tag = "0.2.13";
    hash = "sha256-lS/U42uBpfT0M8mlqGklG8tYB5qMrMnLK4+V89yFcH0=";
  };

  pathPkgs = [ zip ];
}
