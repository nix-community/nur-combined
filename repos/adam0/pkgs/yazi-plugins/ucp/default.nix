{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "ucp.yazi";
  version = "0-unstable-2026-11-18";

  src = fetchFromGitHub {
    owner = "simla33";
    repo = pname;
    rev = "c2e676b9afb68b782243b31b7c9fb2577567fbd8";
    hash = "sha256-lB5qevKZCAORwM2HUU/yQO3udVAOe3CcjbQuYV4c/f4=";
  };

  meta = {
    # keep-sorted start
    description = "Integrates yazi copy/paste with system clipboard similar to GUI file managers";
    homepage = "https://github.com/simla33/ucp.yazi";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
