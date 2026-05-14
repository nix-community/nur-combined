{ config, ... }:

{
  imports = [ ../library/systemd-alert.system.nix ];

  config.services.postfix = {
    enable = true;

    mapFiles.smtp_sasl_password_maps = config.host.dir + "/assets/smtp-sasl-password-maps.local.postmap";

    settings.main = {
      mydestination = [ ]; # Disable local delivery
      myorigin = "andrew.kvalhe.im";
      relayhost = [ "[email-smtp.us-west-2.amazonaws.com]:587" ];
      smtp_use_tls = "yes";
      smtp_tls_security_level = "encrypt";
      smtp_tls_note_starttls_offer = "yes";
      smtp_sasl_auth_enable = "yes";
      smtp_sasl_security_options = "noanonymous";
      smtp_sasl_password_maps = "hash:/var/lib/postfix/conf/smtp_sasl_password_maps";
    };
  };
}
