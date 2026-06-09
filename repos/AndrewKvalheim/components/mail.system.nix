{ config, lib, ... }:

let
  inherit (builtins) elemAt toFile;
  inherit (config) host;
  inherit (config.networking) hostName;
  inherit (config.services) postfix;
  inherit (lib) splitString;

  mapsDir = "/var/lib/postfix/conf";

  rootAliasParts = splitString "@" postfix.rootAlias;
  rootAliasLocal = elemAt rootAliasParts 0;
  rootAliasDomain = elemAt rootAliasParts 1;
in
{
  imports = [ ../library/systemd-alert.system.nix ];

  config.services.postfix = {
    enable = true;

    mapFiles = {
      sender_canonical_maps = toFile "sender_canonical_maps" ''
        /^(.+)@${hostName}$/ ${hostName}/$1@andrew.kvalhe.im
      '';
      smtp_sasl_password_maps = host.dir + "/assets/smtp-sasl-password-maps.local.postmap";
      virtual_alias_maps = toFile "virtual_alias_maps" ''
        /^(.+)@${hostName}\.localdomain$/ ${rootAliasLocal}+${hostName}/$1@${rootAliasDomain}
      '';
    };

    settings.main = {
      # Disable local delivery
      mydestination = [ ];

      # Rewrite addresses
      sender_canonical_maps = "regexp:${mapsDir}/sender_canonical_maps";
      virtual_alias_maps = "regexp:${mapsDir}/virtual_alias_maps";

      # Relay via SES
      relayhost = [ "[email-smtp.us-west-2.amazonaws.com]:587" ];
      smtp_tls_security_level = "encrypt";
      smtp_tls_note_starttls_offer = "yes";
      smtp_sasl_auth_enable = "yes";
      smtp_sasl_security_options = "noanonymous";
      smtp_sasl_password_maps = "hash:${mapsDir}/smtp_sasl_password_maps";
    };
  };
}
