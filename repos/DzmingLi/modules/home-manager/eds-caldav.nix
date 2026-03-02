{ config, lib, pkgs, ... }:

let
  cfg = config.accounts.calendar;

  edsAccounts = lib.filterAttrs
    (_: acc: acc.eds.enable && acc.remote != null && acc.remote.type == "caldav")
    cfg.accounts;

  parseUrl = url: let
    # Extract host and path from URL like https://host/path/
    withoutScheme = lib.removePrefix "https://" (lib.removePrefix "http://" url);
    parts = lib.splitString "/" withoutScheme;
    host = builtins.head parts;
    path = "/" + lib.concatStringsSep "/" (builtins.tail parts);
  in { inherit host path; };

  mkEdsSourceBase = name: account: extensionSection: let
    remote = account.remote;
    displayName = if account.eds.displayName != null then account.eds.displayName else name;
    parsed = parseUrl remote.url;
  in lib.concatStringsSep "\n" (lib.filter (s: s != "") [
    "[Data Source]"
    "DisplayName=${displayName}"
    "Enabled=true"
    "Parent=caldav-stub"
    ""
    "[Authentication]"
    "Host=${parsed.host}"
    "Method=plain/password"
    "Port=443"
    "ProxyUid=system-proxy"
    "RememberPassword=true"
    (lib.optionalString (remote.userName != null) "User=${remote.userName}")
    "CredentialName="
    "IsExternal=false"
    ""
    "[Security]"
    "Method=tls"
    ""
    "[Offline]"
    "StaySynchronized=true"
    ""
    "[WebDAV Backend]"
    "AvoidIfmatch=false"
    "CalendarAutoSchedule=false"
    "Color="
    "DisplayName=${displayName}"
    "EmailAddress="
    "ResourcePath=${parsed.path}"
    "ResourceQuery="
    (if account.eds.trustSelfSignedCert then "SslTrust=${remote.url}" else "SslTrust=")
    "Order=4294967295"
    "Timeout=90"
    ""
    "[Refresh]"
    "Enabled=true"
    "EnabledOnMeteredNetwork=true"
    "IntervalMinutes=30"
    ""
  ] ++ extensionSection);

  mkEdsSource = name: account: mkEdsSourceBase name account [
    "[Calendar]"
    "BackendName=caldav"
    "Color=${account.eds.color}"
    "Selected=true"
    "Order=0"
  ];

  mkEdsTaskSource = name: account: mkEdsSourceBase name account [
    "[Task List]"
    "BackendName=caldav"
    "Color=${account.eds.color}"
    "Selected=true"
    "Order=0"
  ];

  # Generate the source file and optionally store password in libsecret
  mkActivationScript = name: account: let
    sourceContent = mkEdsSource name account;
    sourceFile = pkgs.writeText "eds-caldav-${name}.source" sourceContent;
    taskSourceContent = mkEdsTaskSource name account;
    taskSourceFile = pkgs.writeText "eds-caldav-${name}-tasks.source" taskSourceContent;
    eds = account.eds;
  in ''
    _eds_dir="${config.xdg.configHome}/evolution/sources"
    $DRY_RUN_CMD mkdir -p "$_eds_dir"
    $DRY_RUN_CMD cp --no-preserve=mode "${sourceFile}" "$_eds_dir/eds-caldav-${name}.source"
    $DRY_RUN_CMD cp --no-preserve=mode "${taskSourceFile}" "$_eds_dir/eds-caldav-${name}-tasks.source"
  '' + lib.optionalString (eds.passwordFile != null) ''
    if [ -f "${eds.passwordFile}" ]; then
      _password=$(tr -d '\n' < "${eds.passwordFile}")
      ${pkgs.python3.withPackages (ps: [ ps.pygobject3 ])}/bin/python3 -c "
import gi
gi.require_version('Secret', '1')
from gi.repository import Secret
schema = Secret.Schema.new('org.gnome.Evolution.Data.Source',
    Secret.SchemaFlags.DONT_MATCH_NAME,
    {'e-source-uid': Secret.SchemaAttributeType.STRING})
import sys
pw = sys.stdin.read()
Secret.password_store_sync(schema, {'e-source-uid': 'eds-caldav-${name}'},
    Secret.COLLECTION_DEFAULT, 'eds-caldav-${name}', pw, None)
Secret.password_store_sync(schema, {'e-source-uid': 'eds-caldav-${name}-tasks'},
    Secret.COLLECTION_DEFAULT, 'eds-caldav-${name}-tasks', pw, None)
" <<< "$_password"
    fi
  '';

in
{
  options.accounts.calendar.accounts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options.eds = {
        enable = lib.mkEnableOption "Evolution Data Server CalDAV source generation";

        displayName = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            Display name for the calendar in EDS.
            Defaults to the account name if not set.
          '';
        };

        color = lib.mkOption {
          type = lib.types.str;
          default = "#3584e4";
          example = "#e01b24";
          description = "Calendar color in hex format.";
        };

        passwordFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = lib.literalExpression ''"''${config.age.secrets.caldav-password.path}"'';
          description = ''
            Path to a file containing the CalDAV password.
            The password will be stored in libsecret for EDS to use.

            For agenix:
              passwordFile = config.age.secrets.caldav-password.path;

            For sops-nix:
              passwordFile = config.sops.secrets.caldav-password.path;
          '';
        };

        trustSelfSignedCert = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to trust self-signed SSL certificates.";
        };
      };
    });
  };

  config = lib.mkIf (edsAccounts != { }) {
    home.activation.eds-caldav-sources =
      lib.hm.dag.entryAfter [ "writeBoundary" ] (
        lib.concatStringsSep "\n" (lib.mapAttrsToList mkActivationScript edsAccounts)
      );
  };
}
