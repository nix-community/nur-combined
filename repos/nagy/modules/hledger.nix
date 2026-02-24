{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.hledger
    pkgs.hledger-ui
    pkgs.hledger-web
    pkgs.hledger-fmt
  ];

  # environment.sessionVariables.LEDGER_FILE = "...";
}
