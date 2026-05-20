{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "ucp.yazi";
  version = "0-unstable-2026-05-18";

  src = fetchFromGitHub {
    owner = "simla33";
    repo = pname;
    rev = "a4b5ce1a2b8a5d77b3d00abd36e3259bff785c38";
    hash = "sha256-jIvooR00smQb8bmS3slj87k4yM9aTeruvhu/1krigZ8=";
  };

  meta = {
    # keep-sorted start
    description = "Integrates yazi copy/paste with system clipboard similar to GUI file managers";
    homepage = "https://github.com/simla33/ucp.yazi";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
