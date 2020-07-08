{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.aerc;

  accountConfFile = with cfg;
    generators.toINI
      { } {
      Personal = {
        source = "imaps://${gUsername}:${gPassword}@imap.gmail.com:993";
        outgoing = "smtp+plain://${gUsername}:${gPassword}@smtp.gmail.com:587";
        default = "INBOX";
        smtp-starttls = "yes";
        from =
          if fullName != "" then
            "${fullName} <${gUsername}@gmail.com>"
          else
            "${gUsername}@gmail.com";
        copy-to = "Sent";
      };
    };

  activationScript = with config.xdg; ''
    $DRY_RUN_CMD install -Dm644 ${pkgs.aerc}/share/aerc/aerc.conf -t ${configHome}/aerc
    $DRY_RUN_CMD install -Dm644 ${pkgs.aerc}/share/aerc/binds.conf -t ${configHome}/aerc
  '' + optionalString (cfg.gUsername != "" && cfg.gPassword != "") ''
    $DRY_RUN_CMD eval "echo '${accountConfFile}' > ${configHome}/aerc/accounts.conf"
    $DRY_RUN_CMD chmod 600 ${configHome}/aerc/accounts.conf
  '';
in
{
  meta.maintainers = with maintainers; [ sikmir ];

  options.programs.aerc = {
    enable = mkEnableOption "aerc is an email client for your terminal";

    package = mkOption {
      type = types.package;
      default = pkgs.aerc;
      defaultText = literalExample "pkgs.aerc";
      description = "aerc package to install.";
    };

    gUsername = mkOption {
      type = types.str;
      default = "";
      description = "Google username.";
    };

    gPassword = mkOption {
      type = types.str;
      default = "";
      description = "Google app password.";
    };

    fullName = mkOption {
      type = types.str;
      default = "";
      description = "Full name.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.activation = {
      accountsConf = config.lib.dag.entryAfter [ "writeBoundary" ] activationScript;
    };
  };
}
