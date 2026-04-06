{
  lib,
  fetchFromGitHub,
  mkYaziPlugin,
}:
mkYaziPlugin rec {
  pname = "ucp.yazi";
  version = "0-unstable-2026-04-05";

  src = fetchFromGitHub {
    owner = "simla33";
    repo = pname;
    rev = "b74651dae2fdb02e5706ec8227b2dd33e00f48a9";
    hash = "sha256-XdDUlu43cZUnYDoKhnXlx15jYqnh6ubrbbrzJ0B45vc=";
  };

  meta = {
    description = "Integrates yazi copy/paste with system clipboard similar to GUI file managers";
    homepage = "https://github.com/simla33/ucp.yazi";
    license = lib.licenses.mit;
  };
}
