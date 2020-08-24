{ config, pkgs, lib, makeWrapper, ... }:

with lib;
let
  mailqueue = pkgs.callPackage ./pkg.nix { };

  cfg = config.kampka.services.msmtp-mailqueue;

  sendmail = pkgs.writeScriptBin "sendmail" ''
    #!${pkgs.runtimeShell}
    set -e
    export MAILQUEUE_DIR="${cfg.mailDir}"
    exec ${mailqueue}/bin/msmtpq "''${extraFlagsArray[@]}" "$@"
  '';

  accountOptions = { name, config, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        description = "The name of the account";
      };

      host = mkOption {
        type = types.str;
        description = "hostname of the smtp server to use";
      };

      port = mkOption {
        type = types.int;
        description = "SMTP port of the server";
        default = 587;
      };

      from = mkOption {
        type = types.str;
        description = "The <from:> mail address used for sending mails";
        default = "root";
      };

      user = mkOption {
        type = types.str;
        description = "The server user name used for authentication";
      };

      password-file = mkOption {
        type = types.str;
        description = "The file containing the server password used for authentication (plain-text)";
      };
    };
  };

  aliasOptions = { name, config, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        description = "The local address";
      };

      aliases = mkOption {
        type = types.listOf types.str;
        description = "A list of aliases for the local address";
      };
    };
  };

  aliasesFile = pkgs.writeText "aliases" ''
    ${concatStringsSep "\n" (map (alias: "${alias.name}: ${(concatStringsSep ", " alias.aliases)}") cfg.aliases)}
  '';

  msmtprc = pkgs.writeText "msmtprc" ''
        defaults
        auth           on
        tls            on
        tls_trust_file /etc/ssl/certs/ca-certificates.crt
        syslog         on
        aliases        ${aliasesFile}

        ${concatStringsSep "\n\n" (
        map
    (
          account: ''
            account        ${account.name}
            host           ${account.host}
            port           ${toString account.port}
            from           ${account.from}
            user           ${account.user}
            passwordeval   "cat ${account.password-file}"
          ''
        )
    cfg.accounts
      )}

        account default : ${cfg.accountDefault}
  '';
in
{
  options.kampka.services.msmtp-mailqueue = {
    enable = mkEnableOption "sendmail drop-in replacement with mail queue for msmtp";

    accounts = mkOption {
      type = types.listOf (types.submodule accountOptions);
    };

    accountDefault = mkOption {
      type = types.str;
      description = "Name of the default account. Must match one of the account names in accounts.";
    };

    aliases = mkOption {
      type = types.listOf (types.submodule aliasOptions);
    };

    mailDir = mkOption {
      type = types.str;
      description = "Directory where the mail queue is stored.";
      default = "/var/spool/msmtpq";
    };

    gpgKeys = mkOption {
      type = types.listOf types.path;
      description = "PGP public keys used for encrypting the mail.";
      default = [ ];
    };

    interval = mkOption {
      type = types.str;
      default = "15min";
      description = ''
        The interval at which to trigger a queue flush.
        Valid values must conform to systemd.time(7) format.
      '';
    };
  };

  config = mkIf cfg.enable {
    users.groups = {
      msmtpq = { };
    };

    users.users = {
      msmtpq = {
        description = "msmtpq queue user";
        isSystemUser = true;
        group = "msmtpq";
        extraGroups = [ "keys" ];
      };
    };

    services.mail.sendmailSetuidWrapper = mkIf config.services.postfix.setSendmail {
      program = "sendmail";
      source = "${sendmail}/bin/sendmail";
      group = "msmtpq";
      setuid = false;
      setgid = true;
    };

    environment.etc."msmtprc".source = msmtprc;
    environment.systemPackages = [ mailqueue sendmail ];

    systemd.services.msmtpq-setup = {
      description = "msmtpq setup";

      path = [ pkgs.coreutils pkgs.acl ];

      script = ''
        set -e
        mkdir -p "${cfg.mailDir}"
        chown msmtpq:msmtpq "${cfg.mailDir}"
        chmod 0773 "${cfg.mailDir}"
        chmod g+s "${cfg.mailDir}"
        setfacl -R -m g:msmtpq:rwx "${cfg.mailDir}"

        mkdir -p /var/lib/msmtpq
        chown -R msmtpq:msmtpq /var/lib/msmtpq
        chmod 700 /var/lib/msmtpq
      '';

      after = [ "local-fs.target" ];
      wantedBy = [ "default.target" "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
      };
    };

    systemd.timers.msmtpq-flush = {
      description = "Timer for msmtpq";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnActiveSec = cfg.interval;
        OnUnitActiveSec = cfg.interval;
        Unit = "msmtpq-flush.service";
      };
    };

    systemd.services.msmtpq-flush = {
      description = "msmtpq flush";

      environment = {
        MAILQUEUE_DIR = cfg.mailDir;
        MSMTP_CONFIG = msmtprc;
        GPG_ENCRYPT_KEYS = "${concatStringsSep " " cfg.gpgKeys}";
        GNUPGHOME = "/var/lib/msmtpq/.gnupg";
      };

      path = [ mailqueue pkgs.coreutils pkgs.utillinux ];

      requires = [ "msmtpq-setup.service" ];

      serviceConfig = {
        ExecStart = "${mailqueue}/bin/msmtpq-flush";
        Type = "oneshot";
        User = "msmtpq";
        PrivateTmp = true;
        WorkingDirectory = cfg.mailDir;
      };
    };
  };
}
