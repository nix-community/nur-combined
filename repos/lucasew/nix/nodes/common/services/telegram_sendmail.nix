{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  # Upstream calls pkgs.buildGoModule (Go 1.26). go.mod requires 1.27.2.
  telegramSendmailModule = import "${self.inputs.telegram-sendmail}/nixos-module.nix";
in
{
  imports = [
    (args:
      telegramSendmailModule (args // {
        pkgs = pkgs // {
          buildGoModule = pkgs.buildGo127Module;
        };
      })
    )
  ];

  config = mkIf config.services.telegram-sendmail.enable {
    services.telegram-sendmail.credentialFile = "/var/run/secrets/telegram-sendmail";

    # root-owned: DynamicUser service has no stable system user; systemd reads
    # EnvironmentFile as root before starting the unit.
    sops.secrets.telegram-sendmail = {
      sopsFile = ../../../../secrets/telegram_sendmail.env;
      format = "dotenv";
      mode = "0400";
    };
  };
}
