{ fetchFromGitLab, applyPatches }:

applyPatches { src = fetchFromGitLab {
  domain = "gitlab.inria.fr";
  owner = "batsim";
  repo = "pybatsim";
  rev = "v4.0.0a0";
  sha256 = "sha256-wqWJrlRKH21zOnXWC8MuFojzoSiSArSrQ84yVEUEnxg=";
}; patches = [
  ./400a0-0001-bs-loosen-pyzmq-version-constraint.patch
  ./400a0-0002-bs-loosen-pandas-version-constraint.patch
]; }
