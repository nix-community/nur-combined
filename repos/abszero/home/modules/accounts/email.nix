{ config, lib, ... }:

let
  inherit (lib) types mkOption;
  cfg = config.abszero;
in

{
  options.abszero.emails = mkOption {
    type = types.attrs;
    default = { };
  };

  config.accounts.email.accounts = cfg.emails;
}
