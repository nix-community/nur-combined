{
  config,
  pkgs,
  lib,
  # nur,
  ...
}:

let
  cfg = config.nagy.hledger;
  self = import ../. { inherit pkgs; };
in
{

  options.nagy.hledger = {
    enable = lib.mkEnableOption "hledger config";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.hledger
      pkgs.hledger-ui
      pkgs.hledger-web
      # nur.repos.nagy.hledger-fmt
      self.hledger-fmt
    ];

    # environment.sessionVariables.LEDGER_FILE = "...";
  };
}
