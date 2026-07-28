{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vacu.pm3Wiki.msmtp;
  # based on https://github.com/NixOS/nixpkgs/blob/bcd464ccd2a1a7cd09aa2f8d4ffba83b761b1d0e/nixos/modules/programs/msmtp.nix#L91
  mkValueString =
    v:
    if v == true then
      "on"
    else if v == false then
      "off"
    else
      lib.generators.mkValueStringDefault { } v;
  mkKeyValueString = k: v: "${k} ${mkValueString v}";
  mkInnerSectionString =
    attrs: builtins.concatStringsSep "\n" (lib.mapAttrsToList mkKeyValueString attrs);
  msmtprc = pkgs.writeText "msmtprc" ''
    defaults
    ${mkInnerSectionString cfg.defaults}

    account default
    ${cfg.extraConfig}
  '';
in
{
  options.vacu.pm3Wiki.msmtp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    # based on https://github.com/NixOS/nixpkgs/blob/bcd464ccd2a1a7cd09aa2f8d4ffba83b761b1d0e/nixos/modules/programs/msmtp.nix#L29
    defaults = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      example = {
        aliases = "/etc/aliases";
        port = 587;
        tls = true;
      };
      description = ''
        Default values applied to all accounts.
        See {manpage}`msmtp(1)` for the available options.
      '';
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra lines to add to the msmtp configuration verbatim.
        See {manpage}`msmtp(1)` for the syntax and available options.
      '';
    };
  };

  config.services.phpfpm.pools."dokuwiki-wiki.pm3.dev".phpOptions = lib.mkIf cfg.enable ''
    [mail function]
    sendmail_path = "${pkgs.msmtp}/bin/sendmail --file=${msmtprc} -t -i"

    mail.log = "syslog"
  '';
}
