{
  config,
  reIf,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.repack.snm;
in
{
  imports = [
    inputs.snm.nixosModule
  ];
  options = {
  };

  config = mkIf cfg.enable {
    mailserver = {
      enable = true;
      fqdn = "box.nyaw.xyz";
      domains = [
        "nyaw.xyz"
        "aeon.onl"
        "box.nyaw.xyz" # recommend
      ];
      # mailDirectory = "/var/vmail/mails";
      fullTextSearch = {
        enable = true;
        # index new email as they arrive
        autoIndex = true;
        # this only applies to plain text attachments, binary attachments are never indexed
        enforced = "body";
      };
      stateVersion = 3;

      loginAccounts = {
        "i@box.nyaw.xyz".hashedPassword = "$2b$05$FF2.vIyaX4fgr2C95FqAL.TxzKbgTTMZMMfQaieA5Lrc8owq5pTw2";
        "vault@nyaw.xyz".hashedPassword = "$2b$05$M2lKwY49FwkDauq1az24Vul4ShpbP.mLDSW6yJRINtqFAH0uIRy1i";
        "oidc@nyaw.xyz".hashedPassword = "$2b$05$1Ldyp3RD.O9DzK67JDdlcOGepdmGnwNPYJb7IN/O5AVjO3tg/igxS";
        "misskey@nyaw.xyz".hashedPassword = "$2b$05$1Ldyp3RD.O9DzK67JDdlcOGepdmGnwNPYJb7IN/O5AVjO3tg/igxS";
      };
      extraVirtualAliases = {
        "@nyaw.xyz" = "i@box.nyaw.xyz";
        "@aeon.onl" = "i@box.nyaw.xyz";
      };

      x509.useACMEHost = "box.nyaw.xyz"; # config.mailserver.fqdn;
    };

    services.postfix = {
      settings.main = {

        relayhost = [ "[smtp-relay.brevo.com]:587" ];
        smtp_sasl_auth_enable = "yes";
        smtp_sasl_security_options = "noanonymous";
        smtp_sasl_password_maps = "texthash:${config.vaultix.secrets.postfix-sasl.path}";
        smtp_tls_security_level = lib.mkForce "encrypt";

        smtp_destination_concurrency_limit = "20";
        header_size_limit = "4096000";

      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "sec@nyaw.xyz";
      certs.${config.mailserver.fqdn} = {
        domain = "box.nyaw.xyz";
        dnsProvider = "cloudflare";
        environmentFile = "/var/lib/acme/cloudflare";
      };
    };
  };
}
