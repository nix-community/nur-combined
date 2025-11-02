{
  chntpw,
  fetchFromGitHub,
  lib,
  python313,
  python313Packages,
}:
python313Packages.buildPythonApplication {
  pname = "bt-dualboot";
  version = "1.0.1";
  pyproject = true;

  build-system = [ python313Packages.poetry-core ];
  dependencies = [ chntpw ];

  src = fetchFromGitHub {
    owner = "x2es";
    repo = "bt-dualboot";
    rev = "e3a98df9cc8f6fa6762563401737c9c3f46ac921";
    hash = "sha256-W5i84vAn7yslQbY8FlSnxuJJ9cOcJpAXbXpa33E53ho=";
  };

  meta = {
    description = "User-friendly tool making your bluetooth devices working both in Windows and Linux without re-pairing chore";
    homepage = "https://github.com/x2es/bt-dualboot";
    platforms =
      let
        inherit (lib) intersectLists;
      in
      intersectLists (intersectLists chntpw.meta.platforms python313.meta.platforms) lib.platforms.linux;
  };
}
