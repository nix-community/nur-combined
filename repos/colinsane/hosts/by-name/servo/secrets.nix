{ ... }:

{
  sops.secrets."ddns_afraid" = {
    sopsFile = ../../../secrets/servo.yaml;
  };
  sops.secrets."ddns_he" = {
    sopsFile = ../../../secrets/servo.yaml;
  };

  sops.secrets."dovecot_passwd" = {
    sopsFile = ../../../secrets/servo.yaml;
  };

  sops.secrets."duplicity_passphrase" = {
    sopsFile = ../../../secrets/servo.yaml;
  };

  sops.secrets."freshrss_passwd" = {
    sopsFile = ../../../secrets/servo.yaml;
  };

  sops.secrets."matrix_synapse_secrets" = {
    sopsFile = ../../../secrets/servo.yaml;
  };
  sops.secrets."mautrix_signal_env" = {
    sopsFile = ../../../secrets/servo/mautrix_signal_env.bin;
    format = "binary";
  };

  sops.secrets."mediawiki_pw" = {
    sopsFile = ../../../secrets/servo.yaml;
  };

  sops.secrets."pleroma_secrets" = {
    sopsFile = ../../../secrets/servo.yaml;
  };

  sops.secrets."wg_ovpns_privkey" = {
    sopsFile = ../../../secrets/servo.yaml;
  };
}
