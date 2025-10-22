{
  pkgs,
  lib,
  config,
  ...
}: let
  source = import ./source.nix {inherit pkgs;};
  cfg = config.programs.vscode-remote-wsl-nixos;
in {
  options.programs.vscode-remote-wsl-nixos = {
    enable = lib.mkEnableOption "vscode remote wsl nixos patch";
    non-flakes = lib.mkEnableOption "non-flake support";
  };
  config.home.file = lib.mkIf cfg.enable {
    ".vscode-server/server-env-setup".source =
      if cfg.non-flakes
      then "${source}/non-flakes/server-env-setup"
      else "${source}/server-env-setup";
  };
}
