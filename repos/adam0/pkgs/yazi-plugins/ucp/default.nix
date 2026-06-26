{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "ucp.yazi";
  version = "0-unstable-2026-06-25";

  src = fetchFromGitHub {
    owner = "simla33";
    repo = pname;
    rev = "79043fbbfd39b7b9ae0142d11b315272dd90d33b";
    hash = "sha256-oL3fss8/U6IH2y5B/YdK17h4LvN4XsPypmC+yzJBMnE=";
  };

  meta = {
    # keep-sorted start
    description = "Integrates yazi copy/paste with system clipboard similar to GUI file managers";
    homepage = "https://github.com/simla33/ucp.yazi";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
