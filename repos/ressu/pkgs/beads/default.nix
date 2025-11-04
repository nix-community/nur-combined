{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkgs,
}:

buildGoModule rec {
  pname = "beads";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "steveyegge";
    repo = "beads";
    rev = "v${version}";
    hash = "sha256-rFEVJpIyuive/w2wMgbCsk8RL5RoB4S1PJ+wwOuB8FE=";
  };

  vendorHash = "sha256-DJqTiLGLZNGhHXag50gHFXTVXCBdj8ytbYbPL3QAq8M=";

  go = pkgs.go;
  doCheck = false;

  meta = with lib; {
    description = "Memory upgrade for your coding agent";
    homepage = "https://github.com/steveyegge/beads";
    license = licenses.mit;
    mainProgram = "bd";
  };
}
