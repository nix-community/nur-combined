let
  user = import ../../../../users/service-accounts/csgo.nix;
  autoexec = import ./settings/autoexec.nix { inherit user; };
  gameModeCasual = import ./settings/gameModeCasual.nix { inherit user; };
  gameModes = import ./settings/gameModes.nix { inherit user; };
in { files = [ autoexec gameModeCasual gameModes ]; }
