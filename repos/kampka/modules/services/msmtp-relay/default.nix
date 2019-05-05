{ config, lib, pkgs,  ... }:

with lib;

let

  cfg = config.kampka.services.msmtp-relay;

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
        default = 465;
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
${concatStringsSep "\n" (map (alias: "${alias.name}: ${(concatStringsSep ", " alias.aliases)}") cfg.aliases )}
'';

  msmtprc = pkgs.writeText "msmtprc" ''
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
syslog         on
aliases        ${aliasesFile}

${concatStringsSep "\n\n" (map (account: ''
account        ${account.name}
host           ${account.host}
port           ${toString account.port}
from           ${account.from}
user           ${account.user}
passwordeval   "cat ${account.password-file}"
'') cfg.accounts)}

account default : ${cfg.accountDefault}
'';

in {
  options.kampka.services.msmtp-relay = {
    enable = mkEnableOption "msmtp-relay";

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
  };


  config = mkIf cfg.enable {
    environment.etc."msmtprc".source = msmtprc;

    environment.systemPackages = [ pkgs.msmtp ];
  };
}
