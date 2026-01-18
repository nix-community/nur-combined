{
  lib,
  mkYaziPlugin,
  fetchFromGitHub,
}:
mkYaziPlugin {
  pname = "what-size.yazi";
  version = "unstable-2026-01-05";

  src = fetchFromGitHub {
    owner = "pirafrank";
    repo = "what-size.yazi";
    rev = "179ebf69c9c3ade40cacc0f25e9557a43427c6ca";
    hash = "sha256-7q/45TopqbojNRvYDmP9+hgSGPmiyLHBcV051qpOB2Y=";
  };
  meta = {
    description = "A plugin for yazi to calculate the size of current selection or current working directory";
    homepage = "https://github.com/pirafrank/what-size.yazi";
    license = lib.licenses.mit;
  };
}