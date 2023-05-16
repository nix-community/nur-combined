{ lib, pkgs, config, self, unpackedInputs, ... }:
let
  inherit (lib) mkIf;
in
{
  imports = [ "${unpackedInputs.telegram-sendmail}/nixos-module.nix" ];

  config = mkIf config.services.telegram-sendmail.enable {
    services.telegram-sendmail.credentialFile = "/var/run/secrets/telegram-sendmail";

    sops.secrets.telegram-sendmail = {
      sopsFile = ../../secrets/telegram_sendmail.env;
      owner = config.users.users.telegram_sendmail.name;
      group = config.users.users.telegram_sendmail.group;
      format = "dotenv";
    };
  };
}
