{
  lib,
  fetchFromGitHub,
  mkYaziPlugin,
}:
mkYaziPlugin {
  pname = "ucp.yazi";
  version = "unstable-2025-11-11";

  src = fetchFromGitHub {
    owner = "simla33";
    repo = "ucp.yazi";
    rev = "96f54af95b7f218eb3ffd3dcfcbd743ad3e8c6fb";
    hash = "sha256-SXIxwCYRHLDaFeo1m4QgOPfnOk75E3uObbeu3KLGCTg=";
  };

  meta = {
    description = "Integrates Yazi copy/paste with system clipboard";
    homepage = "https://github.com/simla33/ucp.yazi";
    license = lib.licenses.mit;
  };
}
