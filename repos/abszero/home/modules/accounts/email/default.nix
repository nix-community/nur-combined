{ config, lib, ... }:

let
  inherit (builtins)
    readDir
    readFile
    fromJSON
    warn
    ;
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.accounts.email;

  emailSettings =
    if (readDir ./. ? "email.json") then
      fromJSON (readFile ./email.json)
    else
      warn "email.json is hidden, configuration is incomplete" { };
in

{
  options.abszero.accounts.email.enable = mkEnableOption "Weathercold's email accounts";

  config.accounts.email.accounts = mkIf cfg.enable emailSettings;
}
