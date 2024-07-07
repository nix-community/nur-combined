{ smtprelay }:
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.smtprelay;
in
{
  options.services.smtprelay = {
    enable = mkEnableOption "SMTP relay/proxy server";
    extraConfig = mkOption {
      type = with types; nullOr lines;
      default = null;
      example = ''
        log_format = plain
        remotes = starttls://user:pass@smtp.gmail.com:587
      '';
      description = ''
        These lines go to the end of <literal>smtprelay.ini</literal>.
        See the example <literal>smtprelay.ini</literal> file at
        <link xlink:href="https://github.com/decke/smtprelay/blob/master/smtprelay.ini"/>
        for the available options.
      '';
    };
    hostname = mkOption {
      default = "localhost.localdomain";
      type = with types; uniq string;
      example = "example.com";
      description = ''
        Hostname for this SMTP server.
      '';
    };
    listen = mkOption {
      type = types.listOf types.str;
      default = [ "127.0.0.1:25" "[::1]:25" ];
      description = ''
        Addresses smtprelay should listen to for incoming
        unencrypted connections.
      '';
    };
    read_timeout = mkOption {
      type = types.str;
      default = "60s";
      example = "100us";
      description = ''
        Socket timeout for READ operations
        Duration string as sequence of decimal numbers,
        each with optional fraction and a unit suffix.
        Valid time units are "ns", "us", "ms", "s", "m", "h".
      '';
    };
    write_timeout = mkOption {
      type = types.str;
      default = "60s";
      example = "100us";
      description = ''
        Socket timeout for WRITE operations
        Duration string as sequence of decimal numbers,
        each with optional fraction and a unit suffix.
        Valid time units are "ns", "us", "ms", "s", "m", "h".
      '';
    };
    data_timeout = mkOption {
      type = types.str;
      default = "5m";
      example = "100us";
      description = ''
        Socket timeout for DATA operations
        Duration string as sequence of decimal numbers,
        each with optional fraction and a unit suffix.
        Valid time units are "ns", "us", "ms", "s", "m", "h".
      '';
    };
    max_message_size = mkOption {
      type = types.ints.unsigned;
      default = 10240000;
      example = 20480000;
      description = ''
        Max message size in bytes.
      '';
    };
    max_recipients = mkOption {
      type = types.ints.unsigned;
      default = 100;
      example = 10;
      description = ''
        Max recipients per mail.
      '';
    };
    allowed_nets = mkOption {
      type = types.listOf types.str;
      default = [ "127.0.0.0/8" "::1/128" ];
      description = ''
        Networks that are allowed to send mails to us.
        Allows any address if given empty list.
      '';
    };
    allowed_sender = mkOption {
      type = types.str;
      default = "";
      example = "^(.*)@localhost.localdomain$";
      description = ''
        Regular expression for valid FROM EMail addresses.
        If set to "", then any sender is permitted.
      '';
    };
    allowed_recipients = mkOption {
      type = types.str;
      default = "";
      example = "^(.*)@localhost.localdomain$";
      description = ''
        Regular expression for valid TO EMail addresses.
        If set to "", then any recipient is permitted.
      '';
    };
    remotes = mkOption {
      type = types.listOf types.str;
      example = [
        "starttls://user:pass@smtp.gmail.com:587"
        "starttls://user:pass@smtp.mailgun.org:587"
      ];
      description = ''
        List of SMTP servers to relay the mails to.
        If not set, mails are discarded.
      '';
    };
    command = mkOption {
      type = with types; nullOr str;
      default = null;
      description = ''
        External command to pipe messages to.
      '';
    };
  };
  config = mkIf cfg.enable {
    systemd.services.smtprelay = let
      fixValue = n: v:
        if builtins.isList v then
          lib.concatStringsSep " " v
          else (
            if v == null then "" else v
          );
      isIn = v: blacklist: lib.any (x: x == v) blacklist;
      smptprelay_ini_text = let
        fixed_conf =
          (lib.mapAttrs fixValue
            (lib.filterAttrs ( n: v: !(isIn n ["enable" "extraConfig"])) cfg)
          );
      in lib.generators.toINI {} {
        passbolt = fixed_conf;
      };
      smptprelay_ini = pkgs.writeText "smtprelay.ini"
      "${smptprelay_ini_text}\n${
        lib.optionalString (cfg.extraConfig != null)
        cfg.extraConfig
      }";
    in {
      description = "SMTP relay/proxy server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = [ "${smtprelay}/bin/smtprelay -config ${smptprelay_ini}" ];
      };
    };
  };
}
