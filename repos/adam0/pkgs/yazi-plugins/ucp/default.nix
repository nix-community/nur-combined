{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "ucp.yazi";
  version = "0-unstable-2026-11-17";

  src = fetchFromGitHub {
    owner = "simla33";
    repo = pname;
    rev = "1bf33674bacec01b55f43a06ef4979fa05b28bb5";
    hash = "sha256-7XxlzRS39oRQBJcADBY5Tv+foTEPKC2I0pzB194fXyY=";
  };

  meta = {
    # keep-sorted start
    description = "Integrates yazi copy/paste with system clipboard similar to GUI file managers";
    homepage = "https://github.com/simla33/ucp.yazi";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
