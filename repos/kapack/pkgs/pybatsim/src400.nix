{ fetchFromGitLab, applyPatches }:

applyPatches { src = fetchFromGitLab {
  domain = "gitlab.inria.fr";
  owner = "batsim";
  repo = "pybatsim";
  rev = "v4.0.0a0";
  sha256 = "064z0i2m8cnf8fmv80lj52hz720n5v1hpmkm79rns7saajp8k9f2";
}; patches = [ ./400a0-0001-bs-loosen-pyzmq-version-constraint.patch ]; }
