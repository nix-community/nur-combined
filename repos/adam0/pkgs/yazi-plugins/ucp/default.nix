{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "ucp.yazi";
  version = "0-unstable-2026-10-16";

  src = fetchFromGitHub {
    owner = "simla33";
    repo = pname;
    rev = "5ef8203d9d061f57b444b2c031f3b6172b060a03";
    hash = "sha256-G6PiS+srbxNu30Vz9Q1k3thfuQySMuNpdtmwgf6CjQc=";
  };

  meta = {
    # keep-sorted start
    description = "Integrates yazi copy/paste with system clipboard similar to GUI file managers";
    homepage = "https://github.com/simla33/ucp.yazi";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
